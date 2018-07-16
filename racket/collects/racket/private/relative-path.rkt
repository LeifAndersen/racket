#lang racket/base

(provide relative-path-elements->path
         make-path->relative-path-elements)

(define (relative-path-elements->path elems)
  (define wrt-dir (current-load-relative-directory))
  (define rel-elems (for/list ([p (in-list elems)])
                      (if (bytes? p) (bytes->path-element p) p)))
  (cond
    [wrt-dir (apply build-path wrt-dir rel-elems)]
    [(null? rel-elems) (build-path 'same)]
    [else (apply build-path rel-elems)]))

(define (make-path->relative-path-elements [wr-dir (current-write-relative-directory)]
                                           #:who [who #f])
  (when who
    (unless (or (not wr-dir)
                (and (path-string? wr-dir) (complete-path? wr-dir))
                (and (pair? wr-dir)
                     (path-string? (car wr-dir)) (complete-path? (car wr-dir))
                     (path-string? (cdr wr-dir)) (complete-path? (cdr wr-dir))))
      (raise-argument-error who
                            (string-append
                             "(or/c (and/c path-string? complete-path?)\n"
                             "      (cons/c (and/c path-string? complete-path?)\n"
                             "              (and/c path-string? complete-path?))\n"
                             "      #f)")
                            wr-dir)))
  (cond
    [(not wr-dir) (lambda (v) #f)]
    [else
     (define exploded-base-dir 'not-ready)
     (define exploded-wrt-rel-dir 'not-ready)
     (lambda (v)
       (when (and (eq? exploded-base-dir 'not-ready)
                  (path? v))
         (define wrt-dir (and wr-dir (if (pair? wr-dir) (car wr-dir) wr-dir)))
         (define base-dir (and wr-dir (if (pair? wr-dir) (cdr wr-dir) wr-dir)))
         (set! exploded-base-dir (and base-dir (explode-path base-dir)))
         (set! exploded-wrt-rel-dir
               (if (eq? base-dir wrt-dir)
                   '()
                   (list-tail (explode-path wrt-dir)
                              (length exploded-base-dir)))))
       (and exploded-base-dir
            (path? v)
            (let ([exploded (explode-path v)])
              (and (for/and ([base-p (in-list exploded-base-dir)]
                             [p (in-list exploded)])
                     (equal? base-p p))
                   (let loop ([exploded-wrt-rel-dir exploded-wrt-rel-dir]
                              [rel (list-tail exploded (length exploded-base-dir))])
                     (cond
                       [(null? exploded-wrt-rel-dir) (map path-element->bytes rel)]
                       [(and (pair? rel)
                             (equal? (car rel) (car exploded-wrt-rel-dir)))
                        (loop (cdr exploded-wrt-rel-dir) (cdr rel))]
                       [else (append (for/list ([p (in-list exploded-wrt-rel-dir)])
                                       'up)
                                     (for/list ([p (in-list rel)])
                                       (if (path? p) (path-element->bytes p) p)))]))))))]))
