(cl:in-package #:sicl-string)

(defun nstring-upcase (string &key (start 0) end)
  (declare (type string string))
  (let ((length (length string)))
    (when (null end) (setf end length))
    (check-bounding-indices string start end)
    (loop for i from start below end
	  do (setf (char string i) (char-upcase (char string i)))))
  string)

(defun string-upcase (string-designator &key (start 0) end)
  (let* ((string (string string-designator))
	 (copy (copy-string string)))
    (nstring-upcase copy start end)))

(defun nstring-downcase (string &key (start 0) end)
  (declare (type string string))
  (let ((length (length string)))
    (when (null end) (setf end length))
    (check-bounding-indices string start end)
    (loop for i from start below end
	  do (setf (char string i) (char-downcase (char string i)))))
  string)

(defun string-downcase (string-designator &key (start 0) end)
  (let* ((string (string string-designator))
	 (copy (copy-string string)))
    (nstring-downcase copy start end)))

(defun nstring-capitalize (string &key (start 0) end)
  (declare (type string string))
  (let ((length (length string)))
    (when (null end) (setf end length))
    (check-bounding-indices string start end)
    (loop with state = nil
	  for i from start below end
	  for char = (char string i)
	  do (if state
		 (if (alphanumericp char)
		     (setf (char string i) (char-downcase char))
		     (setf state nil))
		 (when (alphanumericp char)
		   (setf (char string i) (char-upcase char))
		   (setf state t)))))
  string)

(defun string-capitalize (string-designator &key (start 0) end)
  (let* ((string (string string-designator))
	 (copy (copy-string string)))
    (nstring-capitalize copy start end)))
