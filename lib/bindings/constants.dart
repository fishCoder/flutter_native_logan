const CLOGAN_INIT_SUCCESS_MMAP = -1010; //初始化成功, mmap内存
const CLOGAN_INIT_SUCCESS_MEMORY = -1020; //初始化成功, 堆内存
const CLOGAN_INIT_FAIL_NOCACHE = -1030; //初始化失败 , 没有缓存
const CLOGAN_INIT_FAIL_NOMALLOC = -1040; //初始化失败 , 没有堆内存
const CLOGAN_INIT_FAIL_HEADER =  -1050; //初始化失败 , 初始化头失败


const CLOGAN_WRITE_SUCCESS = -4010; //写入日志成功
const CLOGAN_WRITE_FAIL_PARAM = -4020; //写入失败, 可变参数错误
const CLOAGN_WRITE_FAIL_MAXFILE = -4030; //写入失败,超过文件最大值
const CLOGAN_WRITE_FAIL_MALLOC = -4040; //写入失败,malloc失败
const CLOGAN_WRITE_FAIL_HEADER = -4050; //写入头失败


const CLOGAN_OPEN_SUCCESS = -2010; //打开文件成功
const CLOGAN_OPEN_FAIL_IO = -2020; //打开文件IO失败
const CLOGAN_OPEN_FAIL_ZLIB = -2030; //打开文件zlib失败
const CLOGAN_OPEN_FAIL_MALLOC = -2040; //打开文件malloc失败
const CLOGAN_OPEN_FAIL_NOINIT = -2050; //打开文件没有初始化失败
const CLOGAN_OPEN_FAIL_HEADER = -2060; //打开文件头失败
const CLOGAN_OPEN_FAIL_JNI = -2070; //jni找不到对应C函数

const CLOGAN_FLUSH_SUCCESS = -5010; //flush日志成功
const CLOGAN_FLUSH_FAIL_INIT = -5020; //初始化失败,日志flush不成功

const Map<int, String> NativeCodeMessage = {
  CLOGAN_INIT_SUCCESS_MMAP: '初始化成功, mmap内存',
  CLOGAN_INIT_SUCCESS_MEMORY: '初始化成功, 堆内存',
  CLOGAN_INIT_FAIL_NOCACHE: '初始化失败 , 没有缓存',
  CLOGAN_INIT_FAIL_NOMALLOC: '初始化失败 , 没有堆内存',
  CLOGAN_INIT_FAIL_HEADER: '初始化失败 , 初始化头失败',

  CLOGAN_WRITE_SUCCESS: '写入日志成功',
  CLOGAN_WRITE_FAIL_PARAM: '写入失败, 可变参数错误',
  CLOAGN_WRITE_FAIL_MAXFILE: '写入失败,超过文件最大值',
  CLOGAN_WRITE_FAIL_MALLOC: '写入失败,malloc失败',
  CLOGAN_WRITE_FAIL_HEADER: '写入头失败',

  CLOGAN_OPEN_SUCCESS: '打开文件成功',
  CLOGAN_OPEN_FAIL_IO: '打开文件IO失败',
  CLOGAN_OPEN_FAIL_ZLIB: '打开文件zlib失败',
  CLOGAN_OPEN_FAIL_MALLOC: '打开文件malloc失败',
  CLOGAN_OPEN_FAIL_NOINIT: '打开文件没有初始化失败',
  CLOGAN_OPEN_FAIL_HEADER: '打开文件头失败',
  CLOGAN_OPEN_FAIL_JNI: 'jni找不到对应C函数',

  CLOGAN_FLUSH_SUCCESS: 'flush日志成功',
  CLOGAN_FLUSH_FAIL_INIT: '初始化失败,日志flush不成功'
};