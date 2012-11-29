#lang racket
(require net/url 
  net/uri-codec
  web-server/stuffers/hmac-sha1
  net/base64
  rackunit)


;need an oauth object that holds all data related to current oauth call
;includes all of the oauth params

; consumer-key
;; required 
; consumer-secret
;; required
; token 
;; required
; token-secret
;; required

;;need to write functions to change all optional fields
; signature-method
;; default ---> HMAC-SHA1
; oauth-version
;; default ---> 1.0
; nonce 
;; default ---> calculated




;;methods for making requests
;;request(http_method,url)


(define oauth-single-user%
  (class object%
    (super-new)
    
    ;; mandatory fields, must be
    ;; set by user
    (init-field consumer-key)
    (init-field consumer-secret)
    (init-field access-token)
    (init-field access-token-secret)
    
    
    ;;;;oauth-single-user constants 
    (define time-stamp (number->string (current-seconds)))
    (define oauth-version "1.0")
    (define signature-method "HMAC-SHA1")
    (define nonce (string-append (number->string (current-seconds))
                 (number->string (random
                        (current-seconds) (make-pseudo-random-generator)))))
    
    (define (get-key-as-string key_and_value)
      (symbol->string (car key_and_value)))
    
    (define (create-param-string list_of_keys param_string) 
      (cond 
        [(empty? list_of_keys) param_string]
        [(equal? param_string "")
         (create-param-string (rest list_of_keys)
                  (string-append (symbol->string(car (first list_of_keys)))
                        "="
                       (cdr (first list_of_keys))))]
        [else 
         (create-param-string (rest list_of_keys) 
                            (string-append param_string "&" 
             (symbol->string (car (first list_of_keys)))
          "="
          (cdr (first list_of_keys))))]))  
  
    ;create list of oauth params
    (define/private (create-oauth-keys-and-values) 
      (list (cons 'oauth_consumer_key consumer-key)
            (cons 'oauth_signature_method signature-method)
            (cons 'oauth_version oauth-version)
            (cons 'oauth_timestamp time-stamp)
            (cons 'oauth_nonce nonce)
            (cons 'oauth_token access-token)))
    
 (define (generate-base-string http-method base-url params)
  ;signature base string is 
   ;http-method || "&" || base-url || "&" || param-string
   ;all values are percent encoded
   ;http-method must be in all caps, e.g. POST
   ;base-url of request, e.g. https://api.twitter.com/1/statuses/update.json
   ;param-string is in x=y format where
   ;x is the key of the param and y is the value of the param
   ;each key and value are followed by a & if another key/value pair exists
  (string-append (string-upcase http-method) "&" 
   (uri-unreserved-encode base-url) "&" 
   (uri-unreserved-encode 
    (create-param-string 
     (sort (percent-encode-keys-and-values 
            (append (create-oauth-keys-and-values) params)) 
       string<? #:key get-key-as-string)
   ""))))  
    
 (define/private (generate-signing-key consumer-secret token-secret)
  ;;signature_key = consumer_secret || "&" || token_secret
  (string-append (uri-unreserved-encode consumer-secret)
   "&"
   (uri-unreserved-encode token-secret)))
    
    (define/private (generate-signature http-method base-url params)
  ;signature = base64(hmac-sha1(signature_base_string, signature_key))
   (uri-unreserved-encode 
    (bytes->string/utf-8
     ;base64-encode returns #"xxxx\r\n"
     ;use regexp-replace to take out \r and \n
     (regexp-replace #rx#"[\r\n]+$" (base64-encode (HMAC-SHA1
      ;create signing key
      (string->bytes/utf-8 
       (generate-signing-key consumer-secret access-token-secret))
      ;create signature base string 
      (string->bytes/utf-8 
       (generate-base-string http-method base-url 
                             (url-query (string->url base-url))))))""))) )
    
    (define/private (generate-oauth-auth-string request-url)
      (string-append "Authorization: OAuth " 
                 "oauth_consumer_key=\"" consumer-key "\","
                 "oauth_nonce=\"" nonce "\"," 
                 "oauth_signature=\"" (generate-signature "get" request-url empty) "\","
                 "oauth_signature_method=\"" signature-method "\","
                 "oauth_timestamp=\"" time-stamp "\","
                 "oauth_token=\"" access-token "\","
                 "oauth_version=\"" oauth-version "\""))
    
     ;percent encode all keys and values of parameter list
     (define (percent-encode-keys-and-values list-of-params)
       (map (lambda (param)
              (cons 
                (string->symbol(uri-unreserved-encode 
                               (symbol->string (car param))))
                (uri-unreserved-encode (cdr param))))
              list-of-params))
    
      (define/public (request http-method base-url)
        (cond
          [(equal? http-method "get")
           (regexp-match
            #px".*"
            (get-pure-port
             (string->url base-url)
             (list
              (generate-oauth-auth-string base-url))))]
          [(equal? http-method "post")]
          [else print("Incorrect http-method, get or post only.")]))))





;;;;using oauth library

(define myoauth (new oauth-single-user%  
     [consumer-key "8G7BlW9nABUlRGDX6QdGZw"]
     [consumer-secret "FkM4PBUcoJJCNLT5WU7lLwxiHAKsvgRAfmdFxKb9Nqc"]
     [access-token "784422068-CLtRJUZhtk3osRBGLqQG6aiZDmdNtivcbywY4sPx"]
     [access-token-secret "P4OW31qKvHwTnegMKNRtEf7YVkGFPO9pRufoDfhZM"]))

(send myoauth request "get" "https://api.twitter.com/1.1/friends/ids.json")
;;(send myoauth request "get" "https://api.twitter.com/1.1/search/tweets.json?q=racket")

;;;;questions: 
;; 1. confirm best use of classes/objects in racket

;; 2. best way to parse out parameters in a given url
;; for example how to get
;; "http://www.ex.com/home.json?q=ok" --> "http://www.ex.com/home.json"

;;optional parameters for functions? 
;;could be used for post_data

;;;things to finish
;;params for GET requests
;;POST requests
;;params for POST requests




