WITH
clus_tab AS (
  SELECT id, A.attribute_name aname, A.conditional_operator op, NVL(A.attribute_str_value, ROUND(A.attribute_num_value),4) val, A.attribute_support support, A.attribute_confidence confidence
  FROM TABLE(DBMS_DATA_MINING.GET_MODEL_DETAILS_KM('km_sh_clus_sample')) T
     , TABLE(T.rule.antecedent) A
  WHERE A.attribute_confidence > 0.55
), 
clust AS ( 
  SELECT id, CAST(COLLECT(aPackage.Cattr(aname, op, TO_CHAR(val), support, confidence)) AS Cattrs) cl_attrs
  FROM clus_tab 
  GROUP BY id 
), 
custclus AS ( 
  SELECT T.cust_id, S.cluster_id, S.probability 
  FROM (SELECT cust_id, CLUSTER_SET(km_sh_clus_sample, NULL, 0.2 USING *) pset 
        FROM mining_data_apply_v 
        WHERE cust_id = 101362) T
     , TABLE(T.pset) S 
)
SELECT A.probability prob, A.cluster_id cl_id, B.attr, B.op, B.val, B.supp, B.conf 
FROM custclus A
   , (SELECT T.id, C.* 
      FROM clust T
         , TABLE(T.cl_attrs) C
     ) B 
WHERE A.cluster_id = B.id 
UNION
SELECT A.probability prob, A.cluster_id cl_id, B.attr, B.op, B.val, B.supp, B.conf 
FROM custclus A
   , (SELECT T.id, C.* 
      FROM clust T
         , TABLE(T.cl_attrs) C
     ) B 
WHERE A.cluster_id = B.id 
ORDER BY prob DESC, cl_id ASC, conf DESC, attr ASC, val ASC
