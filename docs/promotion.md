# Image promotion

Run **Promote immutable image** from the Actions tab after `Publish images` succeeds. It accepts only a full `sha-<40 hexadecimal characters>` tag and opens a values-only pull request for the selected environment.

Merge development promotion after checks pass. Treat staging and production promotions as reviewed release decisions; check the provenance attestation, SBOM, image scan, and prior canary evidence before approving.
