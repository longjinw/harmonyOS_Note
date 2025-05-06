// 导入 RDB 模块
import relationalStore from '@ohos.data.relationalStore';

// 定义数据库配置
const config: relationalStore.StoreConfig = {
  name: 'my_data.db',  // 数据库名称
  securityLevel: relationalStore.SecurityLevel.S1  // 安全级别
};

// 定义用户表结构
const SQL_CREATE_USER_TABLE = `
  CREATE TABLE IF NOT EXISTS My_users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nickname TEXT NOT NULL,
    account TEXT NOT NULL UNIQUE,
    password TEXT NOT NULL,
    register_time TEXT NOT NULL,
    last_login_time TEXT NOT NULL,
    login_records TEXT NOT NULL
  )`;

// 初始化 RDB 存储
let rdbStore: relationalStore.RdbStore;

// 初始化数据库函数
async function initRdb(context: Context) {
  if (!context) {
    console.error('Context is required to initialize the database');
    return;
  }
  try {
    // 获取 RDB 存储实例
    rdbStore = await relationalStore.getRdbStore(context, config);
    console.log('RDB store initialized successfully');

    // 创建用户表
    await rdbStore.executeSql(SQL_CREATE_USER_TABLE, null);
    console.log('User table created successfully');
  } catch (error) {
    console.error('Error initializing RDB store:', error);
  }
}

// 导出 initRdb 方法和 rdbStore
export { initRdb, rdbStore };