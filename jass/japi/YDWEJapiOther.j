#ifndef YDWEYDWEJapiOtherIncluded
#define YDWEYDWEJapiOtherIncluded

#include "japi\\YDWEJapi.j"

library YDWEYDWEJapiOther
	globals
    	private constant integer CHAT_RECIPIENT_ALL       = 0        // [������]
    	private constant integer CHAT_RECIPIENT_ALLIES    = 1        // [����]
    	private constant integer CHAT_RECIPIENT_OBSERVERS = 2        // [�ۿ���]
    	private constant integer CHAT_RECIPIENT_REFEREES  = 2        // [����]
    	private constant integer CHAT_RECIPIENT_PRIVATE   = 3        // [˽�˵�]
	endglobals

	/*
	native EXDisplayChat     takes player p, integer chat_recipient, string message returns nothing
	*/

	function EXDisplayChat     takes player p, integer chat_recipient, string message returns nothing
		call RemoveSaveDirectory("run japi.EXDisplayChat(" + I2S(GetHandleId(p)) + "," + I2S(chat_recipient) + "," + message + ")")
	endfunction

	//=========================================================

	function YDWEDisplayChat takes player p, integer chat_recipient, string message returns nothing
		call EXDisplayChat(p, chat_recipient, message)
	endfunction

endlibrary

#endif  /// YDWEYDWEJapiOtherIncluded
