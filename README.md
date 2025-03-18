# Real-Time Chat Application

This is a real-time chat application developed as part of an iOS assignment. The app allows users to sign up, log in, and engage in one-on-one real-time messaging. It also includes features like typing indicators, message timestamps, and status updates (sent, delivered). The app is built using Firebase for real-time communication and authentication, and follows the MVVM architecture for clean and maintainable code.

---

## Features

- **User Authentication**: Sign up and log in using Firebase Authentication.
- **Real-Time Messaging**: Send and receive messages in real-time using Firebase Firestore.
- **Chat List**: Display recent conversations with the latest message and timestamp.
- **Typing Indicators**: Show when the other user is typing.
- **Message Status**: Track message status (sent, delivered).
- **Offline Support**: Load last messages from local storage when offline (not fully implemented yet).
- **Clean UI**: Custom chat bubbles and animations for a polished user experience.

---

## Technical Implementation

### Architecture
- **MVVM (Model-View-ViewModel)**: The app follows the MVVM architecture to separate concerns and improve maintainability.
- **Dependency Injection**: Used SwiftUI’s environment to inject dependencies like Firebase services.

### Technologies
- **Real-Time Communication**: Firebase Firestore for real-time messaging.
- **Authentication**: Firebase Authentication for user signup and login.
- **Networking**: Firebase SDK for handling real-time data and authentication.
- **Persistence**: CoreData for offline support (partially implemented).
- **UI Framework**: SwiftUI for building the user interface.

### Libraries and Tools
- **Firebase**: For real-time database, authentication, and storage.
- **Combine**: For reactive programming and handling asynchronous tasks.
- **CoreData**: For local storage and offline support.

---

## Setup Instructions

### Prerequisites
- Xcode 13 or later.
- iOS 15 or later.
- Firebase account (for Firebase Firestore and Authentication).

### Steps to Run the Project
1. **Clone the Repository**:
   ```bash
   git clone https://github.com/vish4mi/y_chat.git
   cd y_chat
   ```

2. **Install Dependencies**:
   - Open the project in Xcode.
   - Ensure Firebase is properly configured. Add your `GoogleService-Info.plist` file to the project.

3. **Configure Firebase**:
   - Go to the [Firebase Console](https://console.firebase.google.com/).
   - Create a new project and add an iOS app.
   - Download the `GoogleService-Info.plist` file and add it to your Xcode project.

4. **Run the App**:
   - Build and run the app on a simulator or physical device.

---

## Approach and Trade-offs

### Approach
- **MVVM Architecture**: Ensures separation of concerns and makes the codebase modular and testable.
- **Firebase Integration**: Leveraged Firebase Firestore for real-time messaging and Firebase Authentication for user management.
- **Combine Framework**: Used for reactive programming to handle asynchronous tasks like fetching messages and updating the UI.
- **CoreData for Offline Support**: Implemented local storage to load messages when offline (partially implemented).

### Trade-offs
- **Offline Support**: Due to time constraints, offline support is not fully implemented. Currently, only the last messages are loaded from local storage.
- **Unit Tests**: Unit tests for ViewModel and API handling are not yet implemented.
- **Scalability**: The app is designed for one-on-one and Group chats but still needs some improvement for group chats.

---

## Future Improvements

1. **Offline Support**:
   - Fully implement offline support using CoreData to sync messages when the app comes online.

2. **Unit Tests**:
   - Add unit tests for ViewModel and API handling using XCTest.

3. **Push Notifications**:
   - Implement push notifications to notify users of new messages.

4. **UI Enhancements**:
   - Add more custom animations and improve the overall user experience.

---

## Screenshots

| Login Screen | Chat List | Group Chat Screen | Chat Screen |
|--------------|-----------|-------------------| ------------|
|![Login](https://github.com/user-attachments/assets/5919aa9a-e566-4356-bea1-ba1dae01621b)| ![Chat List](https://github.com/user-attachments/assets/db6021fe-a1da-4ccb-97dd-48e856144590) | ![Group Chat Screen](https://github.com/user-attachments/assets/0e845ffe-ef9d-48c6-adca-65e1373fb584)| ![1-1 Chat](https://github.com/user-attachments/assets/e989b2e7-b2a3-4ec9-88ba-108709378760)|


## Evaluation Criteria

- **Code Structure and Maintainability**: The app follows MVVM architecture, ensuring clean and modular code.
- **Real-Time Communication**: Firebase Firestore is used for real-time messaging.
- **API Handling and Offline Support**: Firebase SDK is used for API handling, and CoreData is partially implemented for offline support.
- **UI/UX Considerations**: The app has a clean and intuitive UI with custom chat bubbles and animations.
- **Error Handling**: Basic error handling is implemented for Firebase operations.
- **Testing Coverage**: Unit tests are not yet implemented.
- **Documentation**: This README provides a clear overview of the project.

---

## Contribution

Contributions are welcome! If you find any issues or have suggestions for improvement, feel free to open an issue or submit a pull request.

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

Let me know if you need further assistance or customization! 🚀
