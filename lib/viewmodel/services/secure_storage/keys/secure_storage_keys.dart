enum SecureStorageKeys {
  getFavoriteCoins('favorite_coins'),
  openaiApiKey('openai_api_key');

  const SecureStorageKeys(this.key);

  final String key;
}
