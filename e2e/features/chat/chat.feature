Feature: Chat with the AI assistant

  Scenario: User sends a message to the AI
    Given the user is on the chat page
    When the user selects "deepseek-r1:1.5b" model
    And the user sends a message "Hello, AI!"
    Then the user should see the message "Hello, AI!" in the chat window
    And the AI response should not be empty
