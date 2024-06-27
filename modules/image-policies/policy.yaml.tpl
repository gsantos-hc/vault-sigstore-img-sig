apiVersion: policy.sigstore.dev/v1alpha1
kind: ClusterImagePolicy
metadata:
  name: "${ policy_name }"
spec:
  mode: "${ enforcement_mode }"
  images:
    - glob: ${ image_pattern }
  authorities:
    - name: "${ authority_name }"
      key:
        kms: "${ authority_key_identifier }"
