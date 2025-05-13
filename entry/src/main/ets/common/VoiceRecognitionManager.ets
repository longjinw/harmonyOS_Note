import { speechRecognizer } from '@kit.CoreSpeechKit';
import { BusinessError } from '@kit.BasicServicesKit';
import promptAction from '@ohos.promptAction';
import common from '@ohos.app.ability.common';
import abilityAccessCtrl from '@ohos.abilityAccessCtrl';

/**
 * 语音识别管理器
 */
export class VoiceRecognitionManager {
  private static instance: VoiceRecognitionManager | undefined;
  private asrEngine: speechRecognizer.SpeechRecognitionEngine | undefined;
  private sessionId: string = '123456';
  private isRecording: boolean = false;
  private onResultCallback: ((text: string) => void) | undefined;

  private constructor() {}

  /**
   * 获取单例实例
   */
  public static getInstance(): VoiceRecognitionManager {
    if (!VoiceRecognitionManager.instance) {
      VoiceRecognitionManager.instance = new VoiceRecognitionManager();
    }
    return VoiceRecognitionManager.instance;
  }

  /**
   * 检查麦克风权限
   */
  private async checkPermission(): Promise<boolean> {
    try {
      const context = getContext() as common.UIAbilityContext;
      const atManager = abilityAccessCtrl.createAtManager();
      const result = await atManager.requestPermissionsFromUser(context, ['ohos.permission.MICROPHONE']);
      return result.authResults[0] === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
    } catch (error) {
      console.error(`检查权限失败: ${error}`);
      return false;
    }
  }

  /**
   * 初始化语音识别
   */
  public async init(onResult: (text: string) => void): Promise<void> {
    try {
      const hasPermission = await this.checkPermission();
      if (!hasPermission) {
        promptAction.showToast({
          message: '请授予麦克风权限',
          duration: 2000
        });
        return;
      }

      this.onResultCallback = onResult;

      // 设置创建引擎参数
      let extraParam: Record<string, Object> = {
        "locate": "CN",
        "recognizerMode": "short"
      };
      let initParamsInfo: speechRecognizer.CreateEngineParams = {
        language: 'zh-CN',
        online: 1,
        extraParams: extraParam
      };

      // 创建引擎
      return new Promise<void>((resolve, reject) => {
        speechRecognizer.createEngine(initParamsInfo, (err: BusinessError, engine: speechRecognizer.SpeechRecognitionEngine) => {
          if (!err) {
            console.info('Succeeded in creating engine.');
            this.asrEngine = engine;
            this.setupListener();
            resolve();
          } else {
            console.error(`Failed to create engine. Code: ${err.code}, message: ${err.message}`);
            reject(err);
          }
        });
      });
    } catch (error) {
      console.error(`初始化失败: ${error}`);
      promptAction.showToast({
        message: '语音识别初始化失败',
        duration: 2000
      });
    }
  }

  /**
   * 设置识别监听器
   */
  private setupListener(): void {
    if (!this.asrEngine) {
      return;
    }

    let setListener: speechRecognizer.RecognitionListener = {
      onStart: (sessionId: string, eventMessage: string) => {
        console.info(`onStart, sessionId: ${sessionId} eventMessage: ${eventMessage}`);
        this.isRecording = true;
      },
      onEvent: (sessionId: string, eventCode: number, eventMessage: string) => {
        console.info(`onEvent, sessionId: ${sessionId} eventCode: ${eventCode} eventMessage: ${eventMessage}`);
      },
      onResult: (sessionId: string, result: speechRecognizer.SpeechRecognitionResult) => {
        console.info(`onResult, sessionId: ${sessionId} result: ${JSON.stringify(result)}`);
        if (result && result.result && this.onResultCallback) {
          this.onResultCallback(result.result);
        }
      },
      onComplete: (sessionId: string, eventMessage: string) => {
        console.info(`onComplete, sessionId: ${sessionId} eventMessage: ${eventMessage}`);
        this.isRecording = false;
      },
      onError: (sessionId: string, errorCode: number, errorMessage: string) => {
        console.error(`onError, sessionId: ${sessionId} errorCode: ${errorCode} errorMessage: ${errorMessage}`);
        this.isRecording = false;
      }
    }

    this.asrEngine.setListener(setListener);
  }

  /**
   * 开始语音识别（从麦克风输入）
   */
  public startListeningFromMic(): void {
    if (!this.asrEngine || this.isRecording) {
      return;
    }

    try {
      let audioParam: speechRecognizer.AudioInfo = {
        audioType: 'pcm',
        sampleRate: 16000,
        soundChannel: 1,
        sampleBit: 16
      }
      let extraParam: Record<string, Object> = {
        "recognitionMode": 0,
        "vadBegin": 2000,
        "vadEnd": 3000,
        "maxAudioDuration": 20000
      }
      let recognizerParams: speechRecognizer.StartParams = {
        sessionId: this.sessionId,
        audioInfo: audioParam,
        extraParams: extraParam
      }

      console.info('startListening start');
      this.asrEngine.startListening(recognizerParams);
    } catch (error) {
      console.error(`开始识别失败: ${error}`);
      promptAction.showToast({
        message: '开始识别失败',
        duration: 2000
      });
    }
  }

  /**
   * 开始语音识别（从音频文件输入）
   */
  public startListeningFromAudio(): void {
    if (!this.asrEngine || this.isRecording) {
      return;
    }

    try {
      let recognizerParams: speechRecognizer.StartParams = {
        sessionId: this.sessionId,
        audioInfo: {
          audioType: 'pcm',
          sampleRate: 16000,
          soundChannel: 1,
          sampleBit: 16
        }
      }
      this.asrEngine.startListening(recognizerParams);
    } catch (error) {
      console.error(`开始识别失败: ${error}`);
      promptAction.showToast({
        message: '开始识别失败',
        duration: 2000
      });
    }
  }

  /**
   * 写入音频数据
   */
  public writeAudio(audioData: Uint8Array): void {
    if (!this.asrEngine || !this.isRecording) {
      return;
    }

    try {
      this.asrEngine.writeAudio(this.sessionId, audioData);
    } catch (error) {
      console.error(`写入音频失败: ${error}`);
    }
  }

  /**
   * 获取支持的语言列表
   */
  public async listSupportedLanguages(): Promise<Array<string>> {
    if (!this.asrEngine) {
      return [];
    }

    try {
      let languageQuery: speechRecognizer.LanguageQuery = {
        sessionId: this.sessionId
      };
      return await this.asrEngine.listLanguages(languageQuery);
    } catch (error) {
      console.error(`获取语言列表失败: ${error}`);
      return [];
    }
  }

  /**
   * 停止识别
   */
  public stop(): void {
    if (!this.asrEngine || !this.isRecording) {
      return;
    }

    try {
      this.asrEngine.finish(this.sessionId);
      this.isRecording = false;
    } catch (error) {
      console.error(`停止识别失败: ${error}`);
    }
  }

  /**
   * 取消识别
   */
  public cancel(): void {
    if (!this.asrEngine || !this.isRecording) {
      return;
    }

    try {
      this.asrEngine.cancel(this.sessionId);
      this.isRecording = false;
    } catch (error) {
      console.error(`取消识别失败: ${error}`);
    }
  }

  /**
   * 是否正在录音
   */
  public isRecognizing(): boolean {
    return this.isRecording;
  }
} 