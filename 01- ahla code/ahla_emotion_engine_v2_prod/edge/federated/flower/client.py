import flwr as fl
class Client(fl.client.NumPyClient):
  def get_parameters(self, config): return []
  def fit(self, parameters, config): return parameters, 1, {}
  def evaluate(self, parameters, config): return 0.0, 0, {}
if __name__ == "__main__": fl.client.start_numpy_client(server_address="127.0.0.1:8089", client=Client())
