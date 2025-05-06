// 导入 RDB 模块
import relationalStore from '@ohos.data.relationalStore';

// 定义笔记接口
interface Note {
  id: number;
  title: string;
  content: string;
  createTime: string;
  updateTime: string;
}

// 定义数据库值桶接口
interface NoteValues extends relationalStore.ValuesBucket {
  title: string;
  content: string;
  create_time: string;
  update_time: string;
}

// 定义更新值桶接口
interface UpdateValues extends relationalStore.ValuesBucket {
  title: string;
  content: string;
  update_time: string;
  is_deleted: string;
}

// 定义数据库配置
const config: relationalStore.StoreConfig = {
  name: 'my_data.db',  // 数据库名称
  securityLevel: relationalStore.SecurityLevel.S1  // 安全级别
};

// 定义笔记表结构
const SQL_CREATE_NOTE_TABLE = `
  CREATE TABLE IF NOT EXISTS My_notes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    create_time TEXT NOT NULL,
    update_time TEXT NOT NULL,
    is_deleted INTEGER DEFAULT 0
  )`;

// 初始化 RDB 存储
let rdbStore: relationalStore.RdbStore;

// 初始化数据库函数
async function initRdb(context: Context): Promise<void> {
  if (!context) {
    console.error('Context is required to initialize the database');
    return Promise.reject(new Error('Context is required'));
  }
  try {
    // 获取 RDB 存储实例
    rdbStore = await relationalStore.getRdbStore(context, config);
    console.log('RDB store initialized successfully');

    // 创建笔记表
    await rdbStore.executeSql(SQL_CREATE_NOTE_TABLE, null);
    console.log('Note table created successfully');
    return Promise.resolve();
  } catch (error) {
    console.error('Error initializing RDB store:', error);
    return Promise.reject(new Error('Failed to initialize database'));
  }
}

// 笔记相关操作函数
async function createNote(title: string, content: string): Promise<number> {
  try {
    const currentTime = new Date().toISOString();
    const valuesBucket: NoteValues = {
      'title': title,
      'content': content,
      'create_time': currentTime,
      'update_time': currentTime
    } as NoteValues;
    const insertId = await rdbStore.insert('My_notes', valuesBucket);
    console.log('Note created successfully with id:', insertId);
    return insertId;
  } catch (error) {
    console.error('Error creating note:', error);
    throw new Error('Failed to create note');
  }
}

async function updateNote(noteId: number, title: string, content: string): Promise<number> {
  try {
    const currentTime = new Date().toISOString();
    const valuesBucket: UpdateValues = {
      'title': title,
      'content': content,
      'update_time': currentTime,
      'is_deleted': '0'
    } as UpdateValues;
    const predicates = new relationalStore.RdbPredicates('My_notes');
    predicates.equalTo('id', noteId);
    const rowsUpdated = await rdbStore.update(valuesBucket, predicates);
    console.log('Note updated successfully, rows affected:', rowsUpdated);
    return rowsUpdated;
  } catch (error) {
    console.error('Error updating note:', error);
    throw new Error('Failed to update note');
  }
}

async function getAllNotes(): Promise<Note[]> {
  try {
    const predicates = new relationalStore.RdbPredicates('My_notes');
    predicates.equalTo('is_deleted', 0);
    const resultSet = await rdbStore.query(predicates, ['id', 'title', 'content', 'create_time', 'update_time']);
    const notes: Note[] = [];
    while (resultSet.goToNextRow()) {
      notes.push({
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        title: resultSet.getString(resultSet.getColumnIndex('title')),
        content: resultSet.getString(resultSet.getColumnIndex('content')),
        createTime: resultSet.getString(resultSet.getColumnIndex('create_time')),
        updateTime: resultSet.getString(resultSet.getColumnIndex('update_time'))
      });
    }
    resultSet.close();
    return notes;
  } catch (error) {
    console.error('Error getting notes:', error);
    throw new Error('Failed to get notes');
  }
}

async function deleteNote(noteId: number): Promise<number> {
  try {
    const predicates = new relationalStore.RdbPredicates('My_notes');
    predicates.equalTo('id', noteId);
    const valuesBucket: UpdateValues = {
      'title': '',
      'content': '',
      'update_time': new Date().toISOString(),
      'is_deleted': '1'
    } as UpdateValues;
    const rowsUpdated = await rdbStore.update(valuesBucket, predicates);
    console.log('Note marked as deleted, rows affected:', rowsUpdated);
    return rowsUpdated;
  } catch (error) {
    console.error('Error deleting note:', error);
    throw new Error('Failed to delete note');
  }
}

// 导出所有函数和 rdbStore
export { 
  initRdb, 
  rdbStore, 
  createNote, 
  updateNote, 
  getAllNotes, 
  deleteNote,
  Note,
  NoteValues,
  UpdateValues
};