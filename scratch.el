;; The extensible, customizable, self-documenting, real-time display editor!

(defun render-mandelbrot (&optional width height iterations)
  "Render the mandlebrot set as a string"
  (let* ((width (or width 64))
         (height (or height 24))
         (iterations (or iterations 40))
         (palette ".,:;irsXA243hMHGS#9B&@"))
    (with-temp-buffer
      (dotimes (y height)
        (insert ";; ")
        (dotimes (x width)
          (let* ((cr (+ -2.2 (* 3.2 (/ (float x) width))))
                 (ci (+ -1.2 (* 2.4 (/ (float y) height))))
                 (zr 0.0) (zi 0.0) (n 0))
            (while (and (< n iterations)
                        (< (+ (* zr zr) (* zi zi)) 4.0))
              (let ((next-zr (+ (- (* zr zr) (* zi zi)) cr)))
                (setq zi (+ (* 2 zr zi) ci)
                      zr next-zr))
              (setq n (1+ n)))
            (insert (string
                     (if (= n iterations) ?@
                       (aref palette
                             (/ (* n (1- (length palette)))
                                iterations)))))))
        (insert "\n"))
      (buffer-string))))


(defun insert-picture-current-buffer (picture &optional start-token end-token)
  "Draw a mandlebrot set between the markers in *scratch*"
  (let* ((start-token (or start-token "<PICTURE-BEGIN>"))
         (end-token (or end-token "<PICTURE-END>")))
    (save-excursion
      (goto-char (point-min))
      (when (search-forward start-token nil t)
        (forward-line 1)
        (let ((begin (point)))
          (when (search-forward end-token nil t)
            (beginning-of-line)
            (delete-region begin (point))
            (goto-char begin)
            (insert picture)))))))

(insert-picture-current-buffer
 (render-mandelbrot 64 24 40)
 (concat ";; MANDELBROT" "-BEGIN")
 (concat ";; MANDELBROT" "-END"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; MANDELBROT-BEGIN
;; MANDELBROT-END
