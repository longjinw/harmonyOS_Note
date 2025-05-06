import rdb from '@ohos.data.rdb';
import relationalStore from '@ohos.data.relationalStore';
import { rdbStore } from '../pages/databaseManager';

// 新增: 定义 User 类
export class User {
  private static nextId: number = 1; // 静态变量用于自增序列号
  id: number;  // 序列号
  nickname: string;  // 昵称
  account: string;  // 账号
  password: string;  // 密码
  registerTime: Date;  // 注册时间
  lastLoginTime: Date;  // 最后登录时间
  loginRecords: Date[];  // 登录记录数组

  constructor(nickname: string, account: string, password: string, 
              registerTime: Date = new Date(), lastLoginTime: Date = new Date(), 
              loginRecords: Date[] = []) {
    this.id = User.nextId++; // 使用自增序列号
    this.nickname = nickname;
    this.account = account;
    this.password = password;
    this.registerTime = registerTime;
    this.lastLoginTime = lastLoginTime;
    this.loginRecords = loginRecords;
  }

  // 获取昵称
  getNickname(): string {
    return this.nickname;
  }

  // 设置昵称
  setNickname(nickname: string): void {
    this.nickname = nickname;
  }

  // 保存昵称到数据库
  async saveNicknameToDatabase(): Promise<void> {
    if (!rdbStore) {
      console.error('RDB store is not initialized');
      return;
    }

    try {
      const values: rdb.ValuesBucket = {
        'nickname': this.nickname
      };
      const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates('My_users');
      predicates.equalTo('id', this.id);
      await rdbStore.update(values, predicates);
      console.log('Nickname updated successfully');
    } catch (error) {
      console.error('Error updating nickname:', error);
    }
  }

  // 从数据库获取昵称
  static async getNicknameFromDatabase(id: number): Promise<string | null> {
    if (!rdbStore) {
      console.error('RDB store is not initialized');
      return null;
    }

    try {
      const query: string = `SELECT nickname FROM My_users WHERE id = ?`;
      const resultSet: rdb.ResultSet = await rdbStore.querySql(query, [id]);
      if (resultSet.goToFirstRow()) {
        return resultSet.getString(resultSet.getColumnIndex('nickname'));
      }
      return null;
    } catch (error) {
      console.error('Error getting nickname:', error);
      return null;
    }
  }

  // 获取账号
  getAccount(): string {
    return this.account;
  }

  // 设置账号
  setAccount(account: string): void {
    this.account = account;
  }

  // 保存账号到数据库
  async saveAccountToDatabase(): Promise<void> {
    if (!rdbStore) {
      console.error('RDB store is not initialized');
      return;
    }

    try {
      const values: rdb.ValuesBucket = {
        'account': this.account
      };
      const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates('My_users');
      predicates.equalTo('id', this.id);
      await rdbStore.update(values, predicates);
      console.log('Account updated successfully');
    } catch (error) {
      console.error('Error updating account:', error);
    }
  }

  // 从数据库获取账号
  static async getAccountFromDatabase(id: number): Promise<string | null> {
    if (!rdbStore) {
      console.error('RDB store is not initialized');
      return null;
    }

    try {
      const query: string = `SELECT account FROM My_users WHERE id = ?`;
      const resultSet: rdb.ResultSet = await rdbStore.querySql(query, [id]);
      if (resultSet.goToFirstRow()) {
        return resultSet.getString(resultSet.getColumnIndex('account'));
      }
      return null;
    } catch (error) {
      console.error('Error getting account:', error);
      return null;
    }
  }

  // 获取密码
  getPassword(): string {
    return this.password;
  }

  // 设置密码
  setPassword(password: string): void {
    this.password = password;
  }

  // 保存密码到数据库
  async savePasswordToDatabase(): Promise<void> {
    if (!rdbStore) {
      console.error('RDB store is not initialized');
      return;
    }

    try {
      const values: rdb.ValuesBucket = {
        'password': this.password
      };
      const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates('My_users');
      predicates.equalTo('id', this.id);
      await rdbStore.update(values, predicates);
      console.log('Password updated successfully');
    } catch (error) {
      console.error('Error updating password:', error);
    }
  }

  // 从数据库获取密码
  static async getPasswordFromDatabase(id: number): Promise<string | null> {
    if (!rdbStore) {
      console.error('RDB store is not initialized');
      return null;
    }

    try {
      const query: string = `SELECT password FROM My_users WHERE id = ?`;
      const resultSet: rdb.ResultSet = await rdbStore.querySql(query, [id]);
      if (resultSet.goToFirstRow()) {
        return resultSet.getString(resultSet.getColumnIndex('password'));
      }
      return null;
    } catch (error) {
      console.error('Error getting password:', error);
      return null;
    }
  }

  // 获取注册时间
  getRegisterTime(): Date {
    return this.registerTime;
  }

  // 设置注册时间
  setRegisterTime(registerTime: Date): void {
    this.registerTime = registerTime;
  }

  // 保存注册时间到数据库
  async saveRegisterTimeToDatabase(): Promise<void> {
    if (!rdbStore) {
      console.error('RDB store is not initialized');
      return;
    }

    try {
      const values: rdb.ValuesBucket = {
        'register_time': this.registerTime.toISOString()
      };
      const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates('My_users');
      predicates.equalTo('id', this.id);
      await rdbStore.update(values, predicates);
      console.log('Register time updated successfully');
    } catch (error) {
      console.error('Error updating register time:', error);
    }
  }

  // 从数据库获取注册时间
  static async getRegisterTimeFromDatabase(id: number): Promise<Date | null> {
    if (!rdbStore) {
      console.error('RDB store is not initialized');
      return null;
    }

    try {
      const query: string = `SELECT register_time FROM My_users WHERE id = ?`;
      const resultSet: rdb.ResultSet = await rdbStore.querySql(query, [id]);
      if (resultSet.goToFirstRow()) {
        const timeStr: string = resultSet.getString(resultSet.getColumnIndex('register_time'));
        return new Date(timeStr);
      }
      return null;
    } catch (error) {
      console.error('Error getting register time:', error);
      return null;
    }
  }

  // 获取最后登录时间
  getLastLoginTime(): Date {
    return this.lastLoginTime;
  }

  // 设置最后登录时间
  setLastLoginTime(lastLoginTime: Date): void {
    this.lastLoginTime = lastLoginTime;
  }

  // 保存最后登录时间到数据库
  async saveLastLoginTimeToDatabase(): Promise<void> {
    if (!rdbStore) {
      console.error('RDB store is not initialized');
      return;
    }

    try {
      const values: rdb.ValuesBucket = {
        'last_login_time': this.lastLoginTime.toISOString()
      };
      const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates('My_users');
      predicates.equalTo('id', this.id);
      await rdbStore.update(values, predicates);
      console.log('Last login time updated successfully');
    } catch (error) {
      console.error('Error updating last login time:', error);
    }
  }

  // 从数据库获取最后登录时间
  static async getLastLoginTimeFromDatabase(id: number): Promise<Date | null> {
    if (!rdbStore) {
      console.error('RDB store is not initialized');
      return null;
    }

    try {
      const query: string = `SELECT last_login_time FROM My_users WHERE id = ?`;
      const resultSet: rdb.ResultSet = await rdbStore.querySql(query, [id]);
      if (resultSet.goToFirstRow()) {
        const timeStr: string = resultSet.getString(resultSet.getColumnIndex('last_login_time'));
        return new Date(timeStr);
      }
      return null;
    } catch (error) {
      console.error('Error getting last login time:', error);
      return null;
    }
  }

  // 获取登录记录
  getLoginRecords(): Date[] {
    return this.loginRecords;
  }

  // 添加登录记录
  addLoginRecord(loginTime: Date = new Date()): void {
    this.loginRecords.push(loginTime);
    this.lastLoginTime = loginTime;
  }

  // 保存登录记录到数据库
  async saveLoginRecordsToDatabase(): Promise<void> {
    if (!rdbStore) {
      console.error('RDB store is not initialized');
      return;
    }

    try {
      const values: rdb.ValuesBucket = {
        'login_records': JSON.stringify(this.loginRecords.map(date => date.toISOString()))
      };
      const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates('My_users');
      predicates.equalTo('id', this.id);
      await rdbStore.update(values, predicates);
      console.log('Login records updated successfully');
    } catch (error) {
      console.error('Error updating login records:', error);
    }
  }

  // 从数据库获取登录记录
  static async getLoginRecordsFromDatabase(id: number): Promise<Date[] | null> {
    if (!rdbStore) {
      console.error('RDB store is not initialized');
      return null;
    }

    try {
      const query: string = `SELECT login_records FROM My_users WHERE id = ?`;
      const resultSet: rdb.ResultSet = await rdbStore.querySql(query, [id]);
      if (resultSet.goToFirstRow()) {
        const recordsStr: string = resultSet.getString(resultSet.getColumnIndex('login_records'));
        const records: string[] = JSON.parse(recordsStr);
        return records.map((dateStr: string) => new Date(dateStr));
      }
      return null;
    } catch (error) {
      console.error('Error getting login records:', error);
      return null;
    }
  }

  // 保存到数据库
  async saveToDatabase(): Promise<void> {
    if (!rdbStore) {
      console.error('RDB store is not initialized');
      return;
    }

    try {
      const values: rdb.ValuesBucket = {
        'nickname': this.nickname,
        'account': this.account,
        'password': this.password,
        'register_time': this.registerTime.toISOString(),
        'last_login_time': this.lastLoginTime.toISOString(),
        'login_records': JSON.stringify(this.loginRecords.map(date => date.toISOString()))
      };

      const insertResult: number = await rdbStore.insert('My_users', values);
      this.id = insertResult; // 更新用户对象的id为数据库生成的id
      console.log(`User data saved successfully with ID: ${insertResult}`);
    } catch (error) {
      console.error('Error saving user data to database:', error);
    }
  }

  // 从数据库读取
  static async fetchFromDatabase(account: string): Promise<User | null> {
    if (!rdbStore) {
      console.error('RDB store is not initialized');
      return null;
    }

    try {
      const query: string = `SELECT * FROM My_users WHERE account = ?`;
      const resultSet: rdb.ResultSet = await rdbStore.querySql(query, [account]);

      if (resultSet.goToFirstRow()) {
        const id: number = resultSet.getLong(resultSet.getColumnIndex('id'));
        const nickname: string = resultSet.getString(resultSet.getColumnIndex('nickname'));
        const account: string = resultSet.getString(resultSet.getColumnIndex('account'));
        const password: string = resultSet.getString(resultSet.getColumnIndex('password'));
        const registerTime: Date = new Date(resultSet.getString(resultSet.getColumnIndex('register_time')));
        const lastLoginTime: Date = new Date(resultSet.getString(resultSet.getColumnIndex('last_login_time')));
        const loginRecordsStr: string = resultSet.getString(resultSet.getColumnIndex('login_records'));
        const loginRecords: string[] = JSON.parse(loginRecordsStr);
        const loginRecordsDates: Date[] = loginRecords.map((dateStr: string) => new Date(dateStr));

        return new User(nickname, account, password, registerTime, lastLoginTime, loginRecordsDates);
      } else {
        console.log('No user found with the given account');
        return null;
      }
    } catch (error) {
      console.error('Error fetching user data from database:', error);
      return null;
    }
  }
}