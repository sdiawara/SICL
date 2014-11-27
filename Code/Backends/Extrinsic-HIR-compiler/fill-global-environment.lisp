(cl:in-package #:sicl-extrinsic-hir-compiler)

(loop for symbol being each external-symbol in '#:common-lisp
      when (special-operator-p symbol)
	do (setf (sicl-env:special-operator symbol *environment*) t))

(setf (sicl-env:constant-variable t *environment*) t)
(setf (sicl-env:constant-variable nil *environment*) nil)

(setf (sicl-env:macro-function 'defmacro *environment*)
      (compile nil
	       (cleavir-code-utilities:parse-macro
		'defmacro
		'(name lambda-list &body body)
		`((eval-when (:compile-toplevel :load-toplevel :execute)
		    (setf (sicl-env:macro-function name *environment*)
			  (compile nil
				   (cleavir-code-utilities:parse-macro
				    name
				    lambda-list
				    body))))))))

(setf (sicl-env:default-setf-expander *environment*)
      (lambda (form)
	(if (symbolp form)
	    (let ((new (gensym)))
	      (values '()
		      '()
		      `(,new)
		      `(setq ,form ,new)
		      form))
	    (let ((temps (loop for arg in (rest form) collect (gensym)))
		  (new (gensym)))
	      (values temps
		      (rest form)
		      `(,new)
		      `(funcall #'(setf ,(first form) ,new ,@temps))
		      `(,(first form) ,@temps))))))

;;; Many very basic functions will refer to CL:ERROR, so before we can
;;; start filling the environment with those basic functions, it is
;;; good to have a preliminary definition of CL:ERROR in the
;;; environment.  That preliminary definition can not do much at this
;;; point, so it just calls the host function named CL:ERROR in a way
;;; that can't fail.  This way of doing it at least lets us inspect
;;; the host stack and the target runtime environment. 
(setf (sicl-env:fdefinition 'cl:error *environment*)
      #'error)

;;; We need to be able to add new functions to the environment, so we
;;; need a definition of (SETF FDEFINITION).
(setf (sicl-env:fdefinition '(setf fdefinition) *environment*)
      (lambda (&rest args)
	(unless (= (length args) 2)
	  (funcall (sicl-env:fdefinition 'error *environment*)
		   "wrong number of arguments"))
	(destructuring-bind (new-function name) args
	  (unless (functionp new-function)
	    (funcall (sicl-env:fdefinition 'error *environment*)
		   "Argument to (SETF FDEFINITION) must be a function ~s"
		   new-function))
	  (unless (or (symbolp name)
		      (and (consp name)
			   (consp (cdr name))
			   (null (cddr name))
			   (eq (car name) 'setf)
			   (symbolp (cadr name))))
	    (funcall (sicl-env:fdefinition 'error *environment*)
		     "(SETF FDEFINITION) must be given a function name, not ~s"
		     name))
	  (setf (sicl-env:fdefinition name *environment*)
		new-function))))

;;; Import some simple functions to from the host to the target
;;; environment.
(defprimitive cl:consp (t))
(defprimitive cl:cons (t t))

(defprimitive cl:numberp (t))
(defprimitive cl:integerp (t))
(defprimitive cl:rationalp (t))

(defprimitive cl:null (t))

(defprimitive cl:symbolp (t))

(defprimitive cl:characterp (t))
(defprimitive cl:char-code (character))
(defprimitive cl:alphanumericp (character))

(defprimitive cl:stringp (t))
