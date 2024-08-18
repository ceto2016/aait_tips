#  (FCM) HTTP v1 API

**To configure the Firebase Cloud Messaging (FCM) HTTP v1 API using the service account JSON file you provided,** 
follow these steps:
## 1. Install and Set Up Google Cloud SDK
Ensure you have the Google Cloud SDK installed on your machine.
```
brew install --cask google-cloud-sdk
```

Authenticate using the service account JSON file:

```
gcloud auth activate-service-account --key-file=path/to/your/service-account.json
```

Replace path/to/your/service-account.json with the actual path to your JSON file.
## 2. Generate an OAuth 2.0 Access Token
Use the following command to generate an access token:
bash
Copy code
gcloud auth print-access-token

This command will output an access token that you will use in your Postman request.
## 3. Update the Postman Collection
Download postman collection from this link:

```
https://api.postman.com/collections/23373251-8af0e974-e3d3-44da-b017-eacb9fbcb797?access_key=PMAT-01J5JHH2R0NRNKQZYSQVY9J5BZ
```

Replace token: In the Postman collection, replace YOUR_ACCESS_TOKEN with the access token you generated in the previous step.
Replace project_id: Use your project_id from the JSON file
## 4. Postman Request Configuration Example
The service account JSON file provides the credentials needed for authentication. Here’s how to configure the Postman request:
Authorization Header:
In the Postman request, set the Authorization header to:
Authorization: Bearer token
Replace token with the token generated in step 2.
### Request URL:
Update the request URL to include your project ID:

```
https://fcm.googleapis.com/v1/projects/{{project_id}}/messages:send
```
Request Body:
The body of the request should look like this:

```
{
  "message": {
    "token": "USER_DEVICE_TOKEN",
    "notification": {
      "title": "Hello World",
      "body": "This is a test notification"
    },
    "data": {
      "key1": "value1",
      "key2": "value2"
    }
  }
}
```
Replace `USER_DEVICE_TOKEN` with the actual device token.
