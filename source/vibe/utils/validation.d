/**
	String validation routines

	Copyright: © 2012 RejectedSoftware e.K.
	License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
	Authors: Sönke Ludwig
*/
module vibe.utils.validation;

import vibe.utils.string;

import std.algorithm;
import std.exception;
import std.conv;
import std.utf;
//import std.net.isemail; // does not link


/** Provides a simple email address validation.

	Note that the validation could be stricter in some cases than required. The user name
	is forced to be ASCII, which is not strictly required as of RFC 6531. It also does not
	allow quotiations for the user name part (RFC 5321).
	
	Invalid email adresses will cause an exception with the error description to be thrown.
*/
string validateEmail(string str, size_t max_length = 64)
{
	enforce(str.length <= 64, "The email address may not be longer than "~to!string(max_length)~"characters.");
	auto at_idx = str.countUntil('@');
	enforce(at_idx > 0, "Email is missing the '@'.");
	validateIdent(str[0 .. at_idx], "!#$%&'*+-/=?^_`{|}~.(),:;<>@[\\]", "An email user name");
	
	auto domain = str[at_idx+1 .. $];
	auto dot_idx = domain.countUntil('.');
	enforce(dot_idx > 0 && dot_idx < str.length-2, "The email domain is not valid.");
	enforce(!domain.anyOf(" @,[](){}<>!\"'%&/\\?*#;:|"), "The email domain contains invalid characters.");
	
	// does not link!?
	//enforce(isEmail(str) == EmailStatusCode.valid, "The email address is invalid.");
	
	return str;
}

/** Validates a user name string.

	User names may only contain ASCII letters and digits or any of the specified additional
	letters.
	
	Invalid user names will cause an exception with the error description to be thrown.
*/
string validateUserName(string str, int min_length = 3, int max_length = 32, string additional_chars = "-_")
{
	enforce(str.length >= min_length,
		"The user name must be at least "~to!string(min_length)~" characters long.");
	enforce(str.length <= max_length,
		"The user name must not be longer than "~to!string(max_length)~" characters.");
	validateIdent(str, additional_chars, "A user name");
	
	return str;
}

/** Validates an identifier string as used in most programming languages.

	The identifier must begin with a letter or with any of the additional_chars and may
	contain only ASCII letters and digits and any of the additional_chars.
	
	Invalid identifiers will cause an exception with the error description to be thrown.
*/
string validateIdent(string str, string additional_chars = "_", string entity_name = "An identifier")
{
	// NOTE: this is meant for ASCII identifiers only!
	foreach( i, char ch; str ){
		if( ch >= 'a' && ch <= 'z' ) continue;
		if( ch >= 'A' && ch <= 'Z' ) continue;
		if( i > 0 && ch >= '0' && ch <= '9' ) continue;
		if( additional_chars.countUntil(ch) >= 0 ) continue;
		if( ch >= '0' && ch <= '9' )
			throw new Exception(entity_name~" must not begin with a number.");
		throw new Exception(entity_name~" may only contain numbers, letters and one of ("~additional_chars~")");
	}
	
	return str;
}

/** Checks a password for minimum complexity requirements
*/
string validatePassword(string str, string str_confirm, size_t min_length = 8, size_t max_length = 64)
{
	enforce(str.length >= min_length,
		"The password must be at least "~to!string(min_length)~" characters long.");
	enforce(str.length <= max_length,
		"The password must not be longer than "~to!string(max_length)~" characters.");
	enforce(str == str_confirm, "The password and the confirmation differ.");
	return str;
}

string validateString(string str, size_t min_length = 0, size_t max_length = 0, string entity_name = "String")
{
	std.utf.validate(str);
	enforce(str.length >= min_length,
		entity_name~" must be at least "~to!string(min_length)~" characters long.");
	enforce(!max_length || str.length <= max_length,
		entity_name~" must not be longer than "~to!string(min_length)~" characters.");
	return str;
}