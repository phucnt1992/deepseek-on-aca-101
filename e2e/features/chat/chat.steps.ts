import { expect, chromium } from '@playwright/test';
import { Given, When, Then, Before } from '@cucumber/cucumber';
import { ChatPage } from '../../models';

let chatPage: ChatPage;

Before(async () => {
  const browser = await chromium.launch({ headless: false });
  const context = await browser.newContext();
  const page = await context.newPage();

  chatPage = new ChatPage(page);
});

Given('the user is on the chat page', async (page: ChatPage) => {
  await page.visit('http://localhost:8080/');
})

When('the user selects "{string}" model', async (model: string) => {
  await chatPage.selectModel(model);
});

When('the user sends the message "{string}"', async (message: string) => {
  await chatPage.sendMessage(message);
});

Then('the user should see the message "{string}" in the chat window', async (expectedMessage: string) => {
  const userMessage = await chatPage.chatUser.innerText();
  expect(userMessage).toContain(expectedMessage);
});

Then('the AI response should not be empty"', async () => {
  const chatResponseBox = chatPage.getChatResponseBox();
  const responseText = await chatResponseBox.innerText();
  expect(responseText).toContain(response);
});

