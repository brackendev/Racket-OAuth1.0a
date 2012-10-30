#lang racket

(require net/url)
(require net/url-connect)
(require openssl)

(define client%
  (class object%

    (init client-key client-secret options)
    
    (define key client-key)
    (define secret client-secret)

    (define/public (get-key) 
      key)
  )
)

;define test-url (string->url "https://dev.twitter.com"))

;define trends-list (string->url "https://api.twitter.com/1/trends/daily.json"))

;url->string trends-list)

;define get-port (get-pure-port test-url))

;(display-pure-port get-port)
;((lambda ( 
    ;(define authorize-path (string->url "https://dev.twitter.com"))   
    ;(define oauth-token-params (list 
    ;(cons 'oauth_consumer_key (oauth-token))))
;  (path/param ((string->url "https://dev.twitter.com") (list 
;    (cons 'oauth_consumer_key (oauth-token)))))
;)))
(define twitter-host "https://dev.twitter.com")
(path/param "https://dev.twitter.com" (list 
    "oauth_consumer_key" "token"))


;;;;;;;REDIRECTION BASED AUTHENTICATION;;;;;;;
;OAuth uses tokens to represent the authorization granted to the
;client by the resource owner. Typically, token credentials are
;issued by the server at the resource owner’s request, after
;authenticating the resource owner’s identity (usually using a
;username and password).
;;;;
;(HTTP)Redirection based authentication is done in 3 steps
;;
;1. The client obtains a set of temporary credentials from the server
;(in the form of an identifier and shared-secret). The temporary
;credentials are used to identify the access request throughout
;the authorization process.
;;
;2. The resource owner authorizes the server to grant the client’s
;access request (identified by the temporary credentials).
;;
;3. The client uses the temporary credentials to request a set of
;token credentials from the server, which will enable it to access
;the resource owner’s protected resources.
;;
;;;

;;;need to send a get request to temp credential path
;;;in this get request we need to have a header filled with
;;;all the oauth fields below
;;
;;;realm 
;;;oauth_nonce - some unique value, example below uses
  ;; sha1(timestamp || str(random))
;;;oauth_timestamp - current UNIX timestamp, seconds since epoch
;;;oauth_consumer_key - twitter provides this, unique to server
;;;oauth_signature_method - HMAC-SHA1
;;;oauth_version - 1.0
;;;oauth_signature - signature calculated over a set of fields
;;;;
;;;;EXAMPLE TEMP CRED HEADER;;;;
;Authorization: OAuth realm="", oauth_nonce="92673243246",
;oauth_timestamp="12642432725", oauth_consumer_key="9874239869",
;oauth_signature_method="HMAC-SHA1", oauth_version="1.0",
;oauth_signature="l%2FXBqib2y423432LCYwby3kCk%3D"
;;;;;
;;note header actual header would have no line breaks or spaces in it

(define request-temp-cred-path "/oauth/request_token") 




;;;;;;;MAKING AUTHENTICATED REQUESTS;;;;;;;
;oauth_consumer_key
;oauth_token
;

