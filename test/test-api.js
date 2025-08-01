const axios = require('axios');
const FormData = require('form-data');
const fs = require('fs');
const path = require('path');

const API_BASE_URL = process.env.API_URL || 'http://localhost:5000';

async function testAPI() {
  console.log('🧪 Testing Full Stack App API...\n');

  try {
    // Test 1: Health Check
    console.log('1. Testing health check...');
    const healthResponse = await axios.get(`${API_BASE_URL}/api/health`);
    console.log('✅ Health check passed:', healthResponse.data);

    // Test 2: Get Users (should be empty initially)
    console.log('\n2. Testing get users...');
    const usersResponse = await axios.get(`${API_BASE_URL}/api/users`);
    console.log('✅ Get users passed:', usersResponse.data);

    // Test 3: Create a test user with image
    console.log('\n3. Testing create user...');
    
    // Create a simple test image (1x1 pixel PNG)
    const testImagePath = path.join(__dirname, 'test-image.png');
    const testImageData = Buffer.from('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==', 'base64');
    fs.writeFileSync(testImagePath, testImageData);

    const formData = new FormData();
    formData.append('name', 'Test User');
    formData.append('age', '25');
    formData.append('image', fs.createReadStream(testImagePath));

    const createResponse = await axios.post(`${API_BASE_URL}/api/users`, formData, {
      headers: {
        ...formData.getHeaders(),
      },
    });
    console.log('✅ Create user passed:', createResponse.data);

    // Test 4: Get Users (should now have one user)
    console.log('\n4. Testing get users after creation...');
    const usersAfterResponse = await axios.get(`${API_BASE_URL}/api/users`);
    console.log('✅ Get users after creation passed:', usersAfterResponse.data);

    // Test 5: Delete the test user
    if (usersAfterResponse.data.length > 0) {
      const userId = usersAfterResponse.data[0].id;
      console.log(`\n5. Testing delete user (ID: ${userId})...`);
      await axios.delete(`${API_BASE_URL}/api/users/${userId}`);
      console.log('✅ Delete user passed');

      // Clean up test image
      fs.unlinkSync(testImagePath);
    }

    console.log('\n🎉 All API tests passed successfully!');
    console.log('\n📋 Test Summary:');
    console.log('   ✅ Health check');
    console.log('   ✅ Get users');
    console.log('   ✅ Create user with image');
    console.log('   ✅ Get users after creation');
    console.log('   ✅ Delete user');

  } catch (error) {
    console.error('\n❌ API test failed:', error.message);
    if (error.response) {
      console.error('Response status:', error.response.status);
      console.error('Response data:', error.response.data);
    }
    process.exit(1);
  }
}

// Run the test
testAPI(); 