# archival note

Archiving this repo because AWS now provide IPAM as a service and I don't see a
need for this anymore, and because maintaining Terraform providers is painful.
It was a fun experiment, though.

# terraform-provider-cloudyipam

Terraform provider for the CloudyIPAM address management system.

This code used to be in https://github.com/jsleeio/cloudyipam but to simplify
CI maintenance is now in its own repository.

# motivations

The original motivation for this Terraform provider (and CloudyIPAM) was
allowing product development teams to share a Kubernetes cluster and nodes
but allow network-level separation of external resources like databases,
even if

* the network addresses of the external resources are not stable
* the source IP address when connecting might be shared with an unrelated app

The high-level plan:

* allow developers to request network addressing like any other resource
* encourage deployment of things like databases in dedicated sets of subnets
* use Kubernetes network policy to constrain traffic to those subnets

# demo walkthrough: AWS region layout

Here's an example of how one might use CloudyIPAM to provide addressing for
infrastructure in AWS's `us-west-2` region, which at this time of writing
appears to have four availability zones, with a likely fifth in the future.
For the sake of brevity, only two availability zones and two levels of
subdivision are depicted here.

# resource types

## `cloudyipam_zone`

A zone is a collection of equal-sized subnets.

## `cloudyipam_subnet`

A subnet is a subdivision of a zone. The size is set at zone creation.  Subnets
can only be allocated or deallocated. All subnets in a zone must be deallocated
(destroyed, in Terraform terms) before the zone can be destroyed.

## top-level addressing layout: /11 per availability zone

```
resource "cloudyipam_zone" "region" {
  name          = "us-west-2"
  range         = "10.0.0.0/8" prefix_length = 11
}

resource "cloudyipam_subnet" "az_a" {
  usage   = "us-west-2a"
  zone_id = cloudyipam_zones.region.id
}

resource "cloudyipam_subnet" "az_b" {
  usage   = "us-west-2b"
  zone_id = cloudyipam_zones.region.id
}
```

## subdividing each availability zone

```
resource "cloudyipam_zone" "az_a" {
  name          = "us-west-2a"
  range         = cloudyipam_subnet.az_a.range
  prefix_length = 14
}

resource "cloudyipam_zone" "az_b" {
  name          = "us-west-2b"
  range         = cloudyipam_subnet.az_b.range
  prefix_length = 14
}
```

# Docker

Docker images are built for this repository. The tags are noted in each
release. The only purpose of these images is to provide a convenient source
from which to retrieve the provider executable, for adding to another container
image.
