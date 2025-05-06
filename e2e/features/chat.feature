Feature: Chat with the AI assistant

  Scenario: User sends a message to the AI
    Given I am on the chat page
    When I send a message "Hello, how are you?"
    Then I should see a response from the AI
    And the response should not be empty

  Scenario: User sends an empty message
    Given I am on the chat page
    When I send an empty message
    Then I should see an error message "Message cannot be empty"
