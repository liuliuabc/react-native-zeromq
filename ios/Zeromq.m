#import <React/RCTBridgeModule.h>
@interface RCT_EXTERN_REMAP_MODULE(ReactNativeZeroMQiOS, Zeromq, NSObject)
RCT_EXTERN_METHOD(socketCreate:(NSInteger)sockType resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject);
RCT_EXTERN_METHOD(socketBind:(NSString *)uuid endpoint:(NSString *)endpoint resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject);
RCT_EXTERN_METHOD(socketConnect:(NSString *)uuid endpoint:(NSString *)endpoint resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject);
RCT_EXTERN_METHOD(socketDisconnect:(NSString *)uuid endpoint:(NSString *)endpoint resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject);
RCT_EXTERN_METHOD(socketClose:(NSString *)uuid resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject);
RCT_EXTERN_METHOD(destory:(BOOL)forced resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject);
RCT_EXTERN_METHOD(setSocketIdentity:(NSString *)uuid value:(NSString *)value resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject);
RCT_EXTERN_METHOD(socketSend:(NSString *)uuid body:(NSArray *)body resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject);
RCT_EXTERN_METHOD(socketRecv:(NSString *)uuid flag:(NSInteger)flag resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject);
RCT_EXTERN_METHOD(socketRecvEvent:(NSString *)uuid flags:(NSInteger)flags resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject);
RCT_EXTERN_METHOD(socketSubscribe:(NSString *)uuid topic:(NSString *)topic resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject);
RCT_EXTERN_METHOD(socketUnsubscribe:(NSString *)uuid topic:(NSString *)topic resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject);
RCT_EXTERN_METHOD(socketMonitor:(NSString *)uuid endpoint:(NSString *)endpoint events:(NSInteger)events resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject);
RCT_EXTERN_METHOD(setMaxReconnectInterval:(NSString *)uuid value:(NSInteger)value resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject);
RCT_EXTERN_METHOD(setSendTimeOut:(NSString *)uuid value:(NSInteger)value resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject);
RCT_EXTERN_METHOD(setReceiveTimeOut:(NSString *)uuid value:(NSInteger)value resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject);
RCT_EXTERN_METHOD(setImmediate:(NSString *)uuid value:(BOOL)value resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject);
RCT_EXTERN_METHOD(setLinger:(NSString *)uuid value:(NSInteger)value resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject);
@end
