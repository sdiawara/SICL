(cl:in-package #:cleavir-cst-to-ast)

(defmethod convert-global-function-reference (cst info global-env system)
  (declare (ignore global-env))
  (cleavir-ast:make-fdefinition-ast
   (cleavir-ast:make-load-time-value-ast `',(cleavir-env:name info)
                                         t
                                         :origin (cst:source cst))))

(defmethod convert-function-reference
    (cst (info cleavir-env:global-function-info) env system)
  (when (not (eq (cleavir-env:inline info) 'cl:notinline))
    (let ((ast (cleavir-env:ast info)))
      (when ast
        (return-from convert-function-reference
          ;; The AST must be cloned because hoisting is destructive.
          (cleavir-ast-transformations:clone-ast ast)))))
  (convert-global-function-reference
   cst info (cleavir-env:global-environment env) system))

(defmethod convert-function-reference
    (cst (info cleavir-env:local-function-info) env system)
  (declare (ignore env system))
  (cleavir-env:identity info))

(defmethod convert-function-reference
    (cst (info cleavir-env:global-macro-info) env system)
  (error 'function-name-names-global-macro
         :expr (cleavir-env:name info)))

(defmethod convert-function-reference
    (cst (info cleavir-env:local-macro-info) env system)
  (error 'function-name-names-local-macro
         :expr (cleavir-env:name info)))

(defmethod convert-function-reference
    (cst (info cleavir-env:special-operator-info) env system)
  (error 'function-name-names-special-operator
         :expr (cleavir-env:name info)))
