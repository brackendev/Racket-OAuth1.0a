#lang racket
(require net/url 
  net/uri-codec
  web-server/stuffers/hmac-sha1
  net/base64
  rackunit)

;(string->url "https://dev.twitter.com/oauth/request_token")
(cons 'symbol (cons "string" empty))
(url-query(string->url "https://dev.twitter.com/1/statuses/update.json?include_entities=true"))
(url-query(string->url "http://sky@www:801/cgi-bin/finger;xyz?name=shriram;host=nw#top"))
(define consumer-key "8G7BlW9nABUlRGDX6QdGZw") 
(define consumer-secret "FkM4PBUcoJJCNLT5WU7lLwxiHAKsvgRAfmdFxKb9Nqc")
(define time-stamp "1352741869");(number->string (current-seconds)))
(define signature-method "HMAC-SHA1")
(define callback "")
(define oauth-version "1.0")
(define nonce "5b322ce5c0565ecddb91a218aca29ee8");(string-append (number->string (current-seconds)) 
                ;(number->string (random 
                    ;(current-seconds) (make-pseudo-random-generator)))))



(define token "784422068-CLtRJUZhtk3osRBGLqQG6aiZDmdNtivcbywY4sPx")
(define OAuth-token-secret "P4OW31qKvHwTnegMKNRtEf7YVkGFPO9pRufoDfhZM")

(define (get-key-as-string key_and_value)
  (symbol->string (car key_and_value)))
(define base-url (string->url "https://dev.twitter.com/1/statuses/update.json?include_entities=true"))

(define (generate-signing-key consumer-secret token-secret)
   ;consumer-secret&token-secret
  (string-append (uri-unreserved-encode consumer-secret)
   "&"
   (uri-unreserved-encode OAuth-token-secret)))

(define (generate-base-string http-method base-url params)
  ;signature base string is 
   ;http-method&base-url&param-string
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

(define (generate-signature http-method base-url params)
  ;signature = base64(hmac-sha1(signature_base_string, signature_key))
   (uri-unreserved-encode 
    (bytes->string/utf-8
     ;base64-encode returns #"xxxx\r\n", 
     ;use regexp-replace to take out \r and \n
     (regexp-replace #rx#"[\r\n]+$" (base64-encode (HMAC-SHA1
      ;create signing key
      (string->bytes/utf-8 
       (generate-signing-key consumer-secret OAuth-token-secret))
      ;create signature base string 
      (string->bytes/utf-8 
       (generate-base-string http-method base-url params))))""))) )
  
;create list of oauth params
(define (create-oauth-keys-and-values) 
  (list (cons 'oauth_consumer_key consumer-key)
   (cons 'oauth_signature_method signature-method)
	(cons 'oauth_version oauth-version)
	(cons 'oauth_timestamp time-stamp)
	(cons 'oauth_nonce nonce)
	(cons 'oauth_token token))
)
;percent encode all keys and values of parameter list
(define (percent-encode-keys-and-values list-of-params)
  (map (lambda (param)
	(cons 
	  (string->symbol(uri-unreserved-encode 
	   (symbol->string (car param))))
	  (uri-unreserved-encode (cdr param))))
   list-of-params)
)

(define (create-param-string list_of_keys param_string) 
  (cond 
    [(empty? list_of_keys) param_string]
    [(equal? param_string "")
      (create-param-string (rest list_of_keys)
        (string-append (symbol->string(car (first list_of_keys)))
                       "="
                       (cdr (first list_of_keys))))]
    [else 
       (create-param-string (rest list_of_keys) (string-append param_string "&" 
        
	  (symbol->string (car (first list_of_keys)))
          "="
          (cdr (first list_of_keys))))]))


;;signature_key = consumer_secret || "&" || token_secret

(define request-url "https://api.twitter.com/1/statuses/home_timeline.json")
(define the-port
  (get-pure-port
    (string->url request-url)
      (list 
      (string-append "Authorization: OAuth ")
      (string-append "oauth_nonce: " nonce)
      (string-append "oauth_signature_method: " signature-method) 
      (string-append "oauth_timestamp: " time-stamp)
      (string-append "oauth_consumer_key: " consumer-key)
      (string-append "oauth_signature: " (generate-signature "get" request-url empty))
      (string-append "oauth_version: " oauth-version))))

(generate-signature "get" "https://api.twitter.com/1/statuses/home_timeline.json" empty)


(regexp-match #px".*" the-port)

