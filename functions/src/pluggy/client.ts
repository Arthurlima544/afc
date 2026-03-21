import axios, { AxiosInstance } from 'axios';

interface PluggyTransaction {
  id: string;
  date: string;
  description: string;
  amount: number;
  type: 'DEBIT' | 'CREDIT';
  status: string;
  accountId: string;
}

interface PluggyAccount {
  id: string;
  name: string;
  type: string;
}

interface PluggyItem {
  id: string;
  status: string;
  connector: {
    name: string;
    imageUrl?: string;
  };
  updatedAt: string;
}

interface PluggyTransactionsResponse {
  total: number;
  totalPages: number;
  page: number;
  results: PluggyTransaction[];
}

export class PluggyClient {
  private readonly baseUrl = 'https://api.pluggy.ai';
  private apiKey: string | null = null;
  private readonly http: AxiosInstance;

  constructor(
    private readonly clientId: string,
    private readonly clientSecret: string,
  ) {
    this.http = axios.create({ baseURL: this.baseUrl });
  }

  async authenticate(): Promise<void> {
    const response = await this.http.post<{ apiKey: string }>('/auth', {
      clientId: this.clientId,
      clientSecret: this.clientSecret,
    });
    this.apiKey = response.data.apiKey;
  }

  private getHeaders(): Record<string, string> {
    if (!this.apiKey) {
      throw new Error('Not authenticated. Call authenticate() first.');
    }
    return { 'X-API-KEY': this.apiKey };
  }

  async createConnectToken(itemId?: string): Promise<string> {
    const body: { itemId?: string } = {};
    if (itemId) {
      body.itemId = itemId;
    }
    const response = await this.http.post<{ accessToken: string }>(
      '/connect_token',
      body,
      { headers: this.getHeaders() },
    );
    return response.data.accessToken;
  }

  async getItem(itemId: string): Promise<PluggyItem> {
    const response = await this.http.get<PluggyItem>(`/items/${itemId}`, {
      headers: this.getHeaders(),
    });
    return response.data;
  }

  async getAccounts(itemId: string): Promise<PluggyAccount[]> {
    const response = await this.http.get<{ results: PluggyAccount[] }>(
      `/accounts?itemId=${itemId}`,
      { headers: this.getHeaders() },
    );
    return response.data.results;
  }

  async getTransactions(
    accountId: string,
    from: string,
    to: string,
  ): Promise<PluggyTransaction[]> {
    const allTransactions: PluggyTransaction[] = [];
    let page = 1;
    let totalPages = 1;

    while (page <= totalPages) {
      const response = await this.http.get<PluggyTransactionsResponse>(
        `/transactions?accountId=${accountId}&from=${from}&to=${to}&pageSize=500&page=${page}`,
        { headers: this.getHeaders() },
      );
      allTransactions.push(...response.data.results);
      totalPages = response.data.totalPages;
      page++;
    }

    return allTransactions;
  }

  async deleteItem(itemId: string): Promise<void> {
    await this.http.delete(`/items/${itemId}`, {
      headers: this.getHeaders(),
    });
  }
}
