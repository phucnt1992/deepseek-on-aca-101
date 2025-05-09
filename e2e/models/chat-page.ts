import { Locator, Page } from 'playwright';

export class ChatPage {
  readonly page: Page;
  readonly chatInput: Locator;
  readonly submitButton: Locator;
  readonly chatUser: Locator;
  readonly chatAssistant: Locator;
  readonly chatResponses: Locator;
  private selectedModel: string;

  constructor(page: Page) {
    this.page = page;
    this.chatInput = this.page.locator('#chat-input');
    this.submitButton = this.page.locator('button[type="submit"]');
    this.chatUser = this.page.locator('.chat-user');
    this.chatAssistant = this.page.locator('.chat-assistant');
  }

  async visit(uri: string): Promise<void> {
    await this.page.goto(uri);
  }

  setSelectedModel(model: string) {
    this.selectedModel = model;
  }

  getChatResponseBox(): Locator {
    if (!this.selectedModel) {
      throw new Error('Model not selected');
    }

    return this.page.locator(`div[aria-label="${this.selectedModel}"]`);
  }

  async sendMessage(message: string): Promise<void> {
    await this.chatInput.fill(message);
    await this.submitButton.click();
  }

  async selectModel(model: string): Promise<void> {
    await this.page.locator('button[aria-label="Select a model"]').click();
    await this.page.locator(`button[aria-label="model-item"][data-value="${model}"]`).click();

    this.setSelectedModel(model);
  }
}
