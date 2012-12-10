# OAuth 1.0a in Racket 
#### by Stephen Baldwin


The Racket Language currently only has an OAuth 2.0 library. Considering that major companies such as Twitter, Tumblr, Netflix, and Vimeo still use OAuth 1.0a for API authentication, I believe this to be a problem. And so for my senior project I decided to write a library that would allow people to communicate with these API’s via OAuth 1.0a in the Racket language. 

This report will give some background information on the OAuth 1.0a protocol and process for authentication. It will also outline what I completed for my senior project as well as what still needs to be done for this library to be robust. 

##OAuth 1.0a: What is it?
“OAuth provides a method for clients to access server resources on behalf of a resource owner (such as a different client or an end-user).  It also provides a process for end-users to authorize third party access to their server resources without sharing their credentials (typically, a username and password pair), using user-agent redirections.” (RFC 5849)  For example, when you (the ‘resource owner’) tweet from a third-party application (the ‘client’), Twitter (the ‘server’) needs to make sure you are authorized to make that tweet and OAuth allows Twitter to authenticate you while not sharing your personal data (e.g. username and password) with the third-party application.  

##3-Legged OAuth (Redirection-Based Authentication)
In order for the resource owner to access their data, they must prove to the server that they are indeed the resource owner. There are a variety of ways of doing this but a very popular way is through HTTP redirections. Pretty much all of the online services that use OAuth 1.0a authorize resource owners in this way. This is also known as 3-legged OAuth because there are 3 steps for a resource owner to gain access to their data. 

1. The server gives the third-party application (the ‘client’) an identifier and a shared secret. This will be used to identify the access request throughout the authentication process. These are also known as temporary credentials.
2. The resource owner authorizes the server to grant access to the third-party application’s request. The temporary credentials identify this request. 

3. The third-party application then uses the set of temporary credentials to request a set of token credentials. Now with these token credentials the third-party application can now access the resource owner’s data on the server. 

Once the client has the token credentials the resource has successfully authenticated and may now make requests for their data until they revoke the access to the client. 

If the client already had a set of token credentials they would not have to go through the HTTP redirections but could immediately start making requests for the user’s data. This is called Single-User OAuth Authentication. 

##What This Library Provides
My library allows resource owner’s to perform Single-User OAuth Authentication in Racket. Through the *oauth-single-user* object users can make GET and POST requests to api urls with OAuth authentication. 

The client (user of the library) must first define a *oauth-single-user* object with their identifer (consumer-key), shared-secret (cosumer-secret), and token credentials (access-token and access-token-secret).  Once this object is initialized the client may then use *get-request* and *post-request* to communicate with the api. 

```racket
(define twitter-oauth (new oauth-single-user%
  [consumer-key "WWWWWWWWWWWWWWWWW"]
  [consumer-secret "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"]
 	[access-token "YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY"]
  [access-token-secret "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"]))
```

There are two functions that my library provides for the *oauth-single-user* object, *get-request* and *post-request*. 

```racket
;string? listof (symbol? any?) -> string? 
(define/public (get-request base-url [params empty]))
```

*get-request* makes a HTTP GET request to the given url. It includes OAuth information of the *oauth-single-user* object it was called with. It takes one required parameter and one optional. The first parameter is the base url to make the HTTP GET request to. The second parameter is a list of url parameters. The second parameter is in the form of a list with each list value being the url parameter’s key, in symbol form, cons’ed with that url key’s value. 

Depending on the api you are communicating with and the url you call, you will get string return values in different forms. In my example I make calls to urls that end with ‘.json’ so twitter replies with json objects in string form.

```racket
; string? listof(symbol? any?) -> string? 
(define/public (post-request base-url post-data))
```

*post-request* makes a HTTP POST request to the given url. It also includes the OAuth information of the *oauth-single-user* object it was called with. Both parameters are mandatory. Again the first parameter is the base-url for the POST request. The second parameter is a list of POST data. The POST data is in the same form as the url parameters in the *get-request* function. 

Just like the *get-request* the return value for *post-request* is in string form, but depends on the api and url you requested. 

Below are some examples of using my library to communicate with the Twitter REST API. 

Now with their defined *oauth-single-user* object, they can use the functions *post-request* and *get-request* to make calls to the twitter api. 

Here is an example of searching tweets for ‘racket language’ using the *get-request* function.
```racket
(send twitter-oauth get-request "https://api.twitter.com/1.1/search/tweets.json" 
      (list (cons 'q "racket language")))
```

Here is an example of tweeting using the *post-request* function. 
```racket
(send twitter-oauth post-request "https://api.twitter.com/1.1/statuses/update.json" 
     	(list (cons 'status "this was tweeted with my Racket OAuth library!!!")))
```

Here is an example of following someone new with the *post-request* function.
```racket
(send twitter-oauth post-request "https://api.twitter.com/1.1/friendships/create.json"
    	 (list (cons 'screen_name "thai510") (cons 'follow "true")))
```

##Future Work
For this to be a helpful library a couple more features would have to be implemented. 

1. Add 3-Legged Authentication functionality. At this point only Single-User Authentication is implemented. This means only resource owners who can get their token credentials directly from the server (eg. api settings) can use my library. I would like it so any resource owner, as long as the client knew it’s consumer key and secret, could authenticate and use my library. 

2. Add parsing helper functions. At the moment all incoming requests are not parsed or organized, just straight xml or json (dependingo the url and api you request). This would probably best be implemented with specific API’s in mind. It would make the library more elegant and simpler to use. 
