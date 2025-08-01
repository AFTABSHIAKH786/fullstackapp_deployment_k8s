import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './App.css';

function App() {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [formData, setFormData] = useState({
    name: '',
    age: '',
    image: null
  });
  const [selectedFile, setSelectedFile] = useState(null);

  const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:5000';

  useEffect(() => {
    fetchUsers();
  }, []);

  const fetchUsers = async () => {
    try {
      setLoading(true);
      const response = await axios.get(`${API_BASE_URL}/api/users`);
      setUsers(response.data);
      setError('');
    } catch (err) {
      setError('Failed to fetch users');
      console.error('Error fetching users:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  const handleFileChange = (e) => {
    const file = e.target.files[0];
    if (file) {
      setSelectedFile(file);
      setFormData(prev => ({
        ...prev,
        image: file
      }));
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!formData.name || !formData.age || !formData.image) {
      setError('Please fill in all fields and select an image');
      return;
    }

    try {
      setError('');
      setSuccess('');
      
      const formDataToSend = new FormData();
      formDataToSend.append('name', formData.name);
      formDataToSend.append('age', formData.age);
      formDataToSend.append('image', formData.image);

      await axios.post(`${API_BASE_URL}/api/users`, formDataToSend, {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      });

      setSuccess('User added successfully!');
      setFormData({ name: '', age: '', image: null });
      setSelectedFile(null);
      fetchUsers();
    } catch (err) {
      setError(err.response?.data?.error || 'Failed to add user');
      console.error('Error adding user:', err);
    }
  };

  const handleDelete = async (id) => {
    if (window.confirm('Are you sure you want to delete this user?')) {
      try {
        await axios.delete(`${API_BASE_URL}/api/users/${id}`);
        setSuccess('User deleted successfully!');
        fetchUsers();
      } catch (err) {
        setError('Failed to delete user');
        console.error('Error deleting user:', err);
      }
    }
  };

  const getImageUrl = (imagePath) => {
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    return `${API_BASE_URL}${imagePath}`;
  };

  return (
    <div className="container">
      <div className="header">
        <h1>User Management App</h1>
        <p>Add users with their name, age, and profile image</p>
      </div>

      <div className="form-container">
        <h2 className="form-title">Add New User</h2>
        
        {error && <div className="error">{error}</div>}
        {success && <div className="success">{success}</div>}

        <form onSubmit={handleSubmit}>
          <div className="form-group">
            <label htmlFor="name">Name:</label>
            <input
              type="text"
              id="name"
              name="name"
              value={formData.name}
              onChange={handleInputChange}
              placeholder="Enter user name"
              required
            />
          </div>

          <div className="form-group">
            <label htmlFor="age">Age:</label>
            <input
              type="number"
              id="age"
              name="age"
              value={formData.age}
              onChange={handleInputChange}
              placeholder="Enter user age"
              min="1"
              max="120"
              required
            />
          </div>

          <div className="form-group">
            <label htmlFor="image">Profile Image:</label>
            <div className="file-input-container">
              <input
                type="file"
                id="image"
                name="image"
                className="file-input"
                onChange={handleFileChange}
                accept="image/*"
                required
              />
              <label 
                htmlFor="image" 
                className={`file-input-label ${selectedFile ? 'has-file' : ''}`}
              >
                {selectedFile ? selectedFile.name : 'Click to select an image (JPG, PNG, GIF)'}
              </label>
            </div>
          </div>

          <button type="submit" className="submit-btn">
            Add User
          </button>
        </form>
      </div>

      <div className="users-container">
        <h2 className="users-title">Users List</h2>
        
        {loading ? (
          <div className="loading">Loading users...</div>
        ) : users.length === 0 ? (
          <div className="loading">No users found. Add your first user above!</div>
        ) : (
          <div className="users-grid">
            {users.map(user => (
              <div key={user.id} className="user-card">
                <img
                  src={getImageUrl(user.image_path)}
                  alt={`${user.name}'s profile`}
                  className="user-image"
                  onError={(e) => {
                    e.target.src = 'https://via.placeholder.com/300x200?text=Image+Not+Found';
                  }}
                />
                <div className="user-info">
                  <h3>{user.name}</h3>
                  <p><strong>Age:</strong> {user.age}</p>
                  <p><strong>Added:</strong> {new Date(user.created_at).toLocaleDateString()}</p>
                  <button
                    onClick={() => handleDelete(user.id)}
                    className="delete-btn"
                  >
                    Delete User
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}

export default App; 