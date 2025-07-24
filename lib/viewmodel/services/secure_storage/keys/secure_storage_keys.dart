enum SecureStorageKeys {
  openaiApiKey('openai_api_key'),
  fallbackApiUsageCount('fallback_api_usage_count');

  const SecureStorageKeys(this.key);

  final String key;
}
