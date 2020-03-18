class LogConfig {
  LogConfig({
    this.debug = true,
    this.expiredTime = 7 * 24 * 60 * 60 * 1000,
    this.cacheRequestLength = 10
  });
  bool debug;
  int expiredTime;
  int cacheRequestLength;
}