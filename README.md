# play-kafka

Dockerized environment to experiment and play with kafka.

## Dependencies ⛓️

- docker
- k3d
- kubectl
## Run 🏃

```bash
# Setup cluster
make create-cluster
make switch-context # Default cluster should show `k3d-dev-cluster`! If not, abort immediately!
# Setup kafka
make create-kafka # This will take 2~3 minutes
# in a terminal, run this target and write a few messages
make publish
# in another terminal, run this target and observe consumed messages
make consume
# Teardown
make delete-cluster
# optional
make k9s # Sets up k9s within correct namespace (requires local k9s dependency)
```

# References 📚

- https://enjoytechnology.netlify.app/2020/05/18/insall-kafka-strimzi-operator-into-k3s/#create-a-kubernetes-cluster
- https://strimzi.io/quickstarts/
