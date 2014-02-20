(cl:in-package #:sicl-clos)

;;; We maintain a CALL HISTORY for each generic function.  The call
;;; history is a proper list, each element of which is a CALL HISTORY
;;; ENTRY.  A call history entry is a dotted list with 2 CONS cells,
;;; so it contains three items:
;;;
;;;   1. A list of unique number of the classes of the required
;;;      arguments for which the specializer profile contains T.  The
;;;      classes are the those that were passed to
;;;      COMPUTE-APPLICABLE-METHODS-USING-CLASSES.  This item is
;;;      located in the CAR of the dotted list representing the call
;;;      history entry.
;;;
;;;   2. A list of applicable methods, as returned by the generic
;;;      function COMPUTE-APPLICABLE-METHODS-USING-CLASSES when called
;;;      with the classes in item 1.  This item is located in the CADR
;;;      of the dotted list representing the call history entry.
;;;
;;;   3. The result of calling COMPUTE-EFFECTIVE-METHOD on the list of
;;;      methods in item 2.  This item is located in the CDDR of the
;;;      dotted list representing the call history entry.
;;;
;;; The discriminating function does the following:
;;;
;;;   1. Compute the list of instance class numbers of the required
;;;      arguments that it was passed and for which the specializer
;;;      profile contains T.
;;;
;;;   2. Check the call history to see whether there is an entry
;;;      containing that list of class numbers in the CAR of the
;;;      entry.  If so, call the effective method in the CDDR of the
;;;      entry and return the result.
;;;
;;;   3. If there is no entry in the call history corresponding to the
;;;      list of class numbers of the current required arguments, then
;;;      call CLASS-OF for each required argument, indpendently of the
;;;      contents of the specializer profile, and then call the
;;;      generic function COMPUTE-APPLICABLE-METHODS-USING-CLASSES
;;;      with the resulting list of classes.  If the generic function
;;;      COMPUTE-APPLICABLE-METHODS-USING-CLASSES returns TRUE as a
;;;      second return value, then call the generic function
;;;      COMPUTE-EFFECTIVE-METHOD with the list of methods returned as
;;;      the first value.  Create a call history entry from the list
;;;      of class number of the classes for which the specializer
;;;      profile contains T, the list of applicable methods, and the
;;;      effective method.  Finally, call the effective method and
;;;      return the result.
;;;
;;;   4. If COMPUTE-APPLICABLE-METHODS-USING-CLASSES returns FALSE as
;;;      a second return value, then instead call the generic function
;;;      COMPUTE-APPLICABLE-METHODS, passing it all the current
;;;      arguments.  If COMPUTE-APPLICABLE-METHODS returns a non-empty
;;;      list of methods, then call COMPUTE-EFFECTIVE-METHOD with that
;;;      list.  Call the resulting effective method and return the
;;;      result.
;;;
;;;   5. If COMPUTE-APPLICABLE-METHODS returns an empty list, then
;;;      call NO-APPLICABLE-METHOD.

;;; The implementation of this function is not complete.  Furthermore,
;;; this is probably not a good location for it.
(defun instance-class-number (instance)
  (if (heap-instance-p instance)
      (standard-instance-access instance 0)
      ;; For now, anything else is considered to be an instance of
      ;; class T, and we know that T has unique number 0.
      0))

;;; This function takes a method and, if it is a standard reader
;;; method or a standard writer method, it replaces it with a method
;;; that does a direct instance access according to the relevant class
;;; in CLASSES.  Otherwise, it returns the METHOD argument unchanged.
(defun maybe-replace-method (method classes)
  (let ((method-class (class-of method)))
    (flet ((slot-location (direct-slot class)
	     (let* ((name (slot-definition-name direct-slot))
		    (effective-slots (class-slots class))
		    (effective-slot (find name effective-slots
					  :key #'slot-definition-name
					  :test #'eq)))
	       (slot-definition-location effective-slot))))
      (cond ((eq method-class *standard-reader-method*)
	     (let* ((direct-slot (accessor-method-slot-definition method))
		    (location (slot-location direct-slot (car classes)))
		    (lambda-expression
		      `(lambda (arguments next-methods)
			 (declare (ignore next-methods))
			 ,(if (consp location)
			      `(car ',location)
			      `(standard-instance-access
				(car arguments) ,location)))))
	       (make-instance *standard-reader-method*
		 :qualifiers '()
		 :specializers (method-specializers method)
		 :lambda-list (method-lambda-list method)
		 :slot-definition direct-slot
		 :documentation nil
		 :function (compile nil lambda-expression))))
	    ((eq method-class *standard-writer-method*)
	     (let* ((direct-slot (accessor-method-slot-definition method))
		    (location (slot-location direct-slot (cadr classes)))
		    (lambda-expression
		      `(lambda (arguments next-methods)
			 ,(if (consp location)
			      `(setf (car ',location)
				     (car arguments))
			      `(setf (standard-instance-access
				      (cadr arguments) ,location)
				     (car arguments))))))
	       (make-instance *standard-writer-method*
		 :qualifiers '()
		 :specializers (method-specializers method)
		 :lambda-list (method-lambda-list method)
		 :slot-definition direct-slot
		 :documentation nil
		 :function (compile nil lambda-expression))))
	    (t
	     method)))))

(defun final-methods (methods classes)
  (loop for method in methods
	collect (maybe-replace-method method classes)))

;;; This function can not itself be the discriminating function of a
;;; generic function, because it also takes the generic function
;;; itself as an argument.  However it can be called by the
;;; discriminating function, in which case the discriminating function
;;; must supply the GENERIC-FUNCTION argument either from a
;;; closed-over variable, from a compiled-in constant, or perhaps by
;;; some other mechanism.
(defun default-discriminating-function (generic-function arguments)
  (let* ((profile (specializer-profile generic-function))
	 (required-argument-count (length profile))
	 (required-arguments (subseq arguments 0 required-argument-count))
	 (class-numbers (loop for argument in required-arguments
			      for p in profile
			      when p
				collect (instance-class-number argument)))
	 (entry (car (member class-numbers (call-history generic-function)
			     :key #'car :test #'equal))))
    (unless (null entry)
      ;; Found an entry, call the effective method of the entry,
      ;; passing it the arguments we received.
      (return-from default-discriminating-function
	(apply (cddr entry) arguments)))
    ;; Come here if the call history did not contain an entry for the
    ;; current arguments.
    (let ((classes (mapcar #'class-of required-arguments))
	  (method-combination
	    (generic-function-method-combination generic-function)))
      (multiple-value-bind (applicable-methods ok)
	  (compute-applicable-methods-using-classes generic-function classes)
	(when ok
	  (let ((effective-method
		  (compute-effective-method
		   generic-function
		   method-combination
		   (final-methods applicable-methods classes))))
	    (push (list* class-numbers applicable-methods effective-method)
		  (call-history generic-function))
	    (return-from default-discriminating-function
	      (apply effective-method arguments))))
	;; Come here if we can't compute the applicable methods using
	;; only the classes of the arguments. 
	(let ((applicable-methods
		(compute-applicable-methods generic-function arguments)))
	  (when (null applicable-methods)
	    (apply #'no-applicable-method generic-function arguments))
	  (let ((effective-method
		  (compute-effective-method generic-function
					    method-combination
					    applicable-methods)))
	    (apply effective-method arguments)))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Load the call history of a generic function.
;;;
;;; We assume we have a standard generic function.  We also assume
;;; that the specializers of each method are classes as opposed to EQL
;;; specializers.  Finally, we assume that the generic function uses
;;; the standard method combination.
;;;
;;; FIXME: Explain what we are doing.

;;; Return all descendents of a class, including the class itself.
(defun all-descendents (class)
  (let ((subclasses (class-direct-subclasses class)))
    (remove-duplicates (cons class
			     (reduce #'append
				     (mapcar #'all-descendents subclasses))))))

(defun cartesian-product (sets)
  (if (null (cdr sets))
      (mapcar #'list (car sets))
      (loop for element in (car sets)
	    append (mapcar (lambda (set)
			     (cons element set))
			   (cartesian-product (cdr sets))))))

;;; CLASSES-OF-METHOD is a list of specializers (which much be classes)
;;; of a single method of the generic function.
(defun add-to-call-history (generic-function classes-of-method)
  (let* ((sets (loop for class in classes-of-method
		     collect (if (eq class *t*)
				 (list class)
				 (all-descendents class))))
	 (all-combinations (cartesian-product sets))
	 (mc (generic-function-method-combination generic-function)))
    (loop for combination in all-combinations
	  for methods = (compute-applicable-methods-using-classes
			 generic-function combination)
	  for em = (compute-effective-method generic-function mc methods)
	  for no-t = (remove *t* combination)
	  for numbers = (mapcar #'unique-number no-t)
	  do (push (list* numbers methods em)
		   (call-history generic-function)))))

(defun load-call-history (generic-function)
  (loop for method in (generic-function-methods generic-function)
	for specializers = (method-specializers method)
	do (add-to-call-history generic-function specializers)))
