// Initial spec for information extraction model.
{
  "dataset_reader": {
    "type": "ie_json",
    "token_indexers": {
      "tokens": {
        "type": "single_id",
        "lowercase_tokens": false
      },
      // "token_characters": {
        // "type": "characters",
      //   "min_padding_length": 5
      // }
      "elmo": {
        "type": "elmo_characters"
      }
    },
    "max_span_width": 10
  },
  "train_data_path": std.extVar("IE_TRAIN_DATA_PATH"),
  "validation_data_path": std.extVar("IE_DEV_DATA_PATH"),
  "test_data_path": std.extVar("IE_TEST_DATA_PATH"),
  "model": {
    "type": "dygie",
    "text_field_embedder": {
      "token_embedders": {
        "tokens": {
          "type": "embedding",
          "pretrained_file": "https://s3-us-west-2.amazonaws.com/allennlp/datasets/glove/glove.6B.300d.txt.gz",
          "embedding_dim": 300,
          "trainable": false
        },
        // "token_characters": {
        //   "type": "character_encoding",
        //   "embedding": {
        //     "num_embeddings": 262,
        //     "embedding_dim": 16
        //   },
        //   "encoder": {
        //     "type": "cnn",
        //     "embedding_dim": 16,
        //     "num_filters": 100,
        //     "ngram_filter_sizes": [5]
        //   }
        // }
        "elmo": {
          "type": "elmo_token_embedder",
          "options_file": "https://s3-us-west-2.amazonaws.com/allennlp/models/elmo/2x4096_512_2048cnn_2xhighway/elmo_2x4096_512_2048cnn_2xhighway_options.json",
          "weight_file": "https://s3-us-west-2.amazonaws.com/allennlp/models/elmo/2x4096_512_2048cnn_2xhighway/elmo_2x4096_512_2048cnn_2xhighway_weights.hdf5",
          "do_layer_norm": false,
          "dropout": 0.5
        }
      }
    },
    "context_layer": {
      "type": "lstm",
      "bidirectional": true,
      "input_size": 1324,
      "hidden_size": 200,
      "num_layers": 1,
      "dropout": 0.2
    },
    "modules": {
      "coref": {
        "mention_feedforward": {
          "input_dim": 2144,
          "num_layers": 2,
          "hidden_dims": 150,
          "activations": "relu",
          "dropout": 0.2
        },
        "antecedent_feedforward": {
          "input_dim": 6452,
          "num_layers": 2,
          "hidden_dims": 150,
          "activations": "relu",
          "dropout": 0.2
        },
        "spans_per_word": 0.4,
        "max_antecedents": 100,
        "initializer": [
          [".*linear_layers.*weight", {"type": "xavier_normal"}],
          [".*scorer._module.weight", {"type": "xavier_normal"}],
          ["_distance_embedding.weight", {"type": "xavier_normal"}]
        ]
      },
      "ner": {
        "mention_feedforward": {
          "input_dim": 2144,
          "num_layers": 2,
          "hidden_dims": 150,
          "activations": "relu",
          "dropout": 0.2
        },
        "spans_per_word": 0.4,
      },
      "relation": {
        "mention_feedforward": {
          "input_dim": 2144,
          "num_layers": 2,
          "hidden_dims": 150,
          "activations": "relu",
          "dropout": 0.2
        },
        "relation_feedforward": {
          "input_dim": 6432,
          "num_layers": 2,
          "hidden_dims": 150,
          "activations": "relu",
          "dropout": 0.2
        },
        "spans_per_word": 0.4,
        "initializer": [
          [".*linear_layers.*weight", {"type": "xavier_normal"}],
          [".*scorer._module.weight", {"type": "xavier_normal"}],
        ]
      }
    },
    "initializer": [
      ["_span_width_embedding.weight", {"type": "xavier_normal"}],
      ["_context_layer._module.weight_ih.*", {"type": "xavier_normal"}],
      ["_context_layer._module.weight_hh.*", {"type": "orthogonal"}]
    ],
    "loss_weights": {           // TODO(dwadden) These are getting passed in as ints.
      "ner": 1.0,
      "coref": 0.0,
      "relation": 0.0
    },
    "lexical_dropout": 0.5,
    "feature_size": 20,
    "max_span_width": 10,
  },
  "iterator": {
    "type": "document",
    "batch_size": 10,
  },
  "validation_iterator": {
    "type": "document",
    "batch_size": 10,
  },
  "trainer": {
    "num_epochs": 25,
    "grad_norm": 5.0,
    "patience" : 10,
    "cuda_device" : 3,
    "validation_metric": "+ner_f1",
    "learning_rate_scheduler": {
      "type": "reduce_on_plateau",
      "factor": 0.5,
      "mode": "max",
      "patience": 2
    },
    "optimizer": {
      "type": "adam"
    },
    "shuffle": false
  }
}