//
//  AppDelegate.m
//  iphonelua
//
//  Created by maxleung on 20/6/16.
//  Copyright © 2016 maxleung. All rights reserved.
//

#import "AppDelegate.h"
#import "lua533/lauxlib.h"
#import "lua533/lapi.h"
#import "lua533/lualib.h"
#import "UILuaLabel.h"
#import "UILuaButton.h"
#import <objc/runtime.h>
@interface AppDelegate ()

@end

@implementation AppDelegate


static UIViewController *uvc;
static lua_State *l;

typedef struct UdContent{
    void* p;
    SEL fun;
}UdContent;


static int new_obj_label(lua_State* l){
    float xp= lua_tonumber(l, 1);
    float yp= lua_tonumber(l, 2);
    float wp= lua_tonumber(l, 3);
    float hp= lua_tonumber(l, 4);
    UILuaLabel *label2 = [[UILuaLabel alloc]initWithFrame:CGRectMake(xp, yp, wp, hp)];
    UdContent* labelContent= lua_newuserdata(l, sizeof(UdContent*));
    labelContent->p =(void*)CFBridgingRetain(label2);
    luaL_setmetatable(l, "uiroot");
    return 1;
}

void doaction(){
    printf("hello");
}


static int new_obj_button(lua_State* l){
    float xp= lua_tonumber(l, 1);
    float yp= lua_tonumber(l, 2);
    float wp= lua_tonumber(l, 3);
    float hp= lua_tonumber(l, 4);
    
    UILuaButton *button = [[UILuaButton alloc]initWithFrame:CGRectMake(xp, yp, wp, hp)];
    [button setTitle:@"yes" forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor greenColor]];
    UdContent* labelContent= lua_newuserdata(l, sizeof(UdContent*));
    [button addTarget:button action:@selector(callback)  forControlEvents:UIControlEventTouchUpInside];
    labelContent->p= (void*)CFBridgingRetain(button);
    unsigned int numberoffun= 0;
    Method *meds= class_copyMethodList([UIButton class], &numberoffun);
    for (Method *p=meds; p<meds+numberoffun; p++) {
        Method const med= *p;
        int medcount= method_getNumberOfArguments(med);
       
        NSString *funname =NSStringFromSelector(method_getName(med));
        
        if([[funname substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"_"] || [[funname substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"."]){
            continue;
        }
        NSString *arglist=[[NSString alloc]init] ;
        
        for (int i=2; i<medcount; i++) {
            char* type = method_copyArgumentType(med,i);
            arglist= [arglist stringByAppendingFormat:@"%@,",[NSString stringWithUTF8String: type]];
            free(type);
        }

        if(arglist.length>0)
            arglist = [arglist substringWithRange:NSMakeRange(0,arglist.length-1)];
        NSLog(@"%@(%@)  return %@", funname,arglist,[NSString stringWithUTF8String:method_copyReturnType(med)] );
        
    }
    
    return 1;
}

static int setuilabel(lua_State* l){
    UdContent *labelContent =(UdContent*)luaL_checkudata(l, 1, "uiroot");
    UILuaLabel *label =  (__bridge UILuaLabel*)labelContent->p;
    const char* txt = lua_tostring(l, 2);
    label.text = [NSString stringWithUTF8String:txt];
    return 0;
}

static int setevent(lua_State* l){
    UdContent *labelContent =(UdContent*)luaL_checkudata(l, 1, "uiroot");

    return 0;
}

static int del(lua_State* l){
    UdContent *labelContent =(UdContent*)luaL_checkudata(l, 1, "uiroot");
    UILuaLabel *label =  (UILuaLabel*)CFBridgingRelease(labelContent->p);
    [label removeFromSuperview];
    return 0;
}



static int autogc(lua_State* l){
    UdContent *labelContent =(UdContent*)luaL_checkudata(l, 1, "uiroot");
    NSLog(@"lua gc %p",labelContent);
    //free(labelContent);
    return 0;
}



static int addtoview(lua_State* l){
    UdContent *p =luaL_checkudata(l, 1, "uiroot");
    UIView *view = (__bridge UIView*)p->p;
    [uvc.view addSubview:view];
    return 0;
}

static const  struct luaL_Reg labellib[] = {
    {"settxt", setuilabel},
    {"setevent",setevent},
    {"del",del},
    {"__gc",autogc},
    {NULL,NULL}
};




static void doluas(const char* path){
    printf("start lua\n");
    l = luaL_newstate();
    luaL_openlibs(l);
   
    luaL_newmetatable(l, "uiroot");
    lua_pushvalue(l, -1);
    lua_setfield(l, -2, "__index");
    luaL_setfuncs(l, labellib, 0);
    lua_settop(l, 0);
    
    int v = lua_gettop(l);
    
    lua_newtable(l);
    lua_pushcfunction(l, new_obj_label);
    lua_setglobal(l, "UILuaLabel");
    lua_pushcfunction(l, new_obj_button);
    lua_setglobal(l, "UILuaButton");
    
    lua_pushcfunction(l, addtoview);
    lua_setglobal(l, "addtoview");
    
    v= luaL_loadfile(l, path);
    lua_pcall(l, 0, 0, 0);

    
    
    if (v!=0){
        lua_error(l);
    }
    printf("end lua st:%i\n",v);
    //lua_close(l);
}






- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    self.window.backgroundColor = [UIColor brownColor];
    [self.window makeKeyAndVisible];
    uvc = [[UIViewController alloc]init];
    self.window.rootViewController= uvc;
    NSString *bundle =[[NSBundle mainBundle] bundlePath];
    NSString *full = [NSString stringWithFormat:@"%@/lua/main.lua",bundle];
    doluas([full UTF8String]);
    // Do any additional setup after loading the view, typically from a nib.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    

}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

