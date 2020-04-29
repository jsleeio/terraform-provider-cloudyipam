FROM scratch
COPY terraform-provider-cloudyipam  /terraform-provider-cloudyipam
ENTRYPOINT ["/terraform-provider-cloudyipam"]
