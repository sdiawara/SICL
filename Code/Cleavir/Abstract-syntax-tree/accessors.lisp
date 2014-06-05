(in-package #:cleavir-ast)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Class AREF-AST
;;;
;;; This AST can be used to read an element of an unspecialized array.
;;; It corresponds roughly to the standard function ROW-MAJOR-AREF.

(defclass aref-ast (ast one-value-ast-mixin)
  ((%array-ast :initarg :array-ast :reader array-ast)
   (%index-ast :initarg :index-ast :reader index-ast)))

(defun make-aref-ast (array-ast index-ast)
  (make-instance 'aref-ast
    :array-ast array-ast
    :index-ast index-ast))

(cleavir-io:define-save-info aref-ast
  (:array-ast array-ast)
  (:index-ast index-ast))

(defmethod children ((ast aref-ast))
  (list (array-ast ast) (index-ast ast)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Class ASET-AST
;;;
;;; This AST can be used to write an element of an unspecialized
;;; array.  It corresponds roughly to a function (SETF
;;; ROW-MAJOR-ASET).  An attempt to compile this AST in a context
;;; where a value is needed will result in an error being signaled.

(defclass aset-ast (ast no-value-ast-mixin)
  ((%array-ast :initarg :array-ast :reader array-ast)
   (%index-ast :initarg :index-ast :reader index-ast)
   (%value-ast :initarg :value-ast :reader value-ast)))

(defun make-aset-ast (array-ast index-ast value-ast)
  (make-instance 'aset-ast
    :array-ast array-ast
    :index-ast index-ast
    :value-ast value-ast))

(cleavir-io:define-save-info aset-ast
  (:array-ast array-ast)
  (:index-ast index-ast)
  (:value-ast value-ast))

(defmethod children ((ast aset-ast))
  (list (array-ast ast) (index-ast ast) (value-ast ast)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Class SHORT-FLOAT-AREF-AST
;;;
;;; This AST can be used to read an element of an array specialized to
;;; SHORT-FLOAT.

(defclass short-float-aref-ast (ast one-value-ast-mixin)
  ((%array-ast :initarg :array-ast :reader array-ast)
   (%index-ast :initarg :index-ast :reader index-ast)))

(defun make-short-float-aref-ast (array-ast index-ast)
  (make-instance 'short-float-aref-ast
    :array-ast array-ast
    :index-ast index-ast))

(cleavir-io:define-save-info short-float-aref-ast
  (:array-ast array-ast)
  (:index-ast index-ast))

(defmethod children ((ast short-float-aref-ast))
  (list (array-ast ast) (index-ast ast)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Class SHORT-FLOAT-ASET-AST
;;;
;;; This AST can be used to write an element of an array specialized
;;; to SHORT-FLOAT.

(defclass short-float-aset-ast (ast no-value-ast-mixin)
  ((%array-ast :initarg :array-ast :reader array-ast)
   (%index-ast :initarg :index-ast :reader index-ast)
   (%value-ast :initarg :value-ast :reader value-ast)))

(defun make-short-float-aset-ast (array-ast index-ast value-ast)
  (make-instance 'short-float-aset-ast
    :array-ast array-ast
    :index-ast index-ast
    :value-ast value-ast))

(cleavir-io:define-save-info short-float-aset-ast
  (:array-ast array-ast)
  (:index-ast index-ast)
  (:value-ast value-ast))

(defmethod children ((ast short-float-aset-ast))
  (list (array-ast ast) (index-ast ast) (value-ast ast)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Class SINGLE-FLOAT-AREF-AST
;;;
;;; This AST can be used to read an element of an array specialized to
;;; SINGLE-FLOAT.

(defclass single-float-aref-ast (ast one-value-ast-mixin)
  ((%array-ast :initarg :array-ast :reader array-ast)
   (%index-ast :initarg :index-ast :reader index-ast)))

(defun make-single-float-aref-ast (array-ast index-ast)
  (make-instance 'single-float-aref-ast
    :array-ast array-ast
    :index-ast index-ast))

(cleavir-io:define-save-info single-float-aref-ast
  (:array-ast array-ast)
  (:index-ast index-ast))

(defmethod children ((ast single-float-aref-ast))
  (list (array-ast ast) (index-ast ast)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Class SINGLE-FLOAT-ASET-AST
;;;
;;; This AST can be used to write an element of an array specialized
;;; to SINGLE-FLOAT.

(defclass single-float-aset-ast (ast no-value-ast-mixin)
  ((%array-ast :initarg :array-ast :reader array-ast)
   (%index-ast :initarg :index-ast :reader index-ast)
   (%value-ast :initarg :value-ast :reader value-ast)))

(defun make-single-float-aset-ast (array-ast index-ast value-ast)
  (make-instance 'single-float-aset-ast
    :array-ast array-ast
    :index-ast index-ast
    :value-ast value-ast))

(cleavir-io:define-save-info single-float-aset-ast
  (:array-ast array-ast)
  (:index-ast index-ast)
  (:value-ast value-ast))

(defmethod children ((ast single-float-aset-ast))
  (list (array-ast ast) (index-ast ast) (value-ast ast)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Class DOUBLE-FLOAT-AREF-AST
;;;
;;; This AST can be used to read an element of an array specialized to
;;; DOUBLE-FLOAT.

(defclass double-float-aref-ast (ast one-value-ast-mixin)
  ((%array-ast :initarg :array-ast :reader array-ast)
   (%index-ast :initarg :index-ast :reader index-ast)))

(defun make-double-float-aref-ast (array-ast index-ast)
  (make-instance 'double-float-aref-ast
    :array-ast array-ast
    :index-ast index-ast))

(cleavir-io:define-save-info double-float-aref-ast
  (:array-ast array-ast)
  (:index-ast index-ast))

(defmethod children ((ast double-float-aref-ast))
  (list (array-ast ast) (index-ast ast)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Class DOUBLE-FLOAT-ASET-AST
;;;
;;; This AST can be used to write an element of an array specialized
;;; to DOUBLE-FLOAT.

(defclass double-float-aset-ast (ast no-value-ast-mixin)
  ((%array-ast :initarg :array-ast :reader array-ast)
   (%index-ast :initarg :index-ast :reader index-ast)
   (%value-ast :initarg :value-ast :reader value-ast)))

(defun make-double-float-aset-ast (array-ast index-ast value-ast)
  (make-instance 'double-float-aset-ast
    :array-ast array-ast
    :index-ast index-ast
    :value-ast value-ast))

(cleavir-io:define-save-info double-float-aset-ast
  (:array-ast array-ast)
  (:index-ast index-ast)
  (:value-ast value-ast))

(defmethod children ((ast double-float-aset-ast))
  (list (array-ast ast) (index-ast ast) (value-ast ast)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Class LONG-FLOAT-AREF-AST
;;;
;;; This AST can be used to read an element of an array specialized to
;;; LONG-FLOAT.

(defclass long-float-aref-ast (ast one-value-ast-mixin)
  ((%array-ast :initarg :array-ast :reader array-ast)
   (%index-ast :initarg :index-ast :reader index-ast)))

(defun make-long-float-aref-ast (array-ast index-ast)
  (make-instance 'long-float-aref-ast
    :array-ast array-ast
    :index-ast index-ast))

(cleavir-io:define-save-info long-float-aref-ast
  (:array-ast array-ast)
  (:index-ast index-ast))

(defmethod children ((ast long-float-aref-ast))
  (list (array-ast ast) (index-ast ast)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Class LONG-FLOAT-ASET-AST
;;;
;;; This AST can be used to write an element of an array specialized
;;; to LONG-FLOAT.

(defclass long-float-aset-ast (ast no-value-ast-mixin)
  ((%array-ast :initarg :array-ast :reader array-ast)
   (%index-ast :initarg :index-ast :reader index-ast)
   (%value-ast :initarg :value-ast :reader value-ast)))

(defun make-long-float-aset-ast (array-ast index-ast value-ast)
  (make-instance 'long-float-aset-ast
    :array-ast array-ast
    :index-ast index-ast
    :value-ast value-ast))

(cleavir-io:define-save-info long-float-aset-ast
  (:array-ast array-ast)
  (:index-ast index-ast)
  (:value-ast value-ast))

(defmethod children ((ast long-float-aset-ast))
  (list (array-ast ast) (index-ast ast) (value-ast ast)))
