{
  apiVersion: 'v1',
  kind: 'Pod',
  metadata: {
    name: 'llama-cpp',
  },
  spec: {
    containers: [
      {
        name: 'server',
        image: 'localhost/llama-cpp',
        command: [
          '/server',
        ],
        args: [
          '-m',
          'models/mistral-7b-v0.1.Q4_K_M.gguf',
          '-c',
          '2048',
          '--host',
          '0.0.0.0',
        ],
        ports: [
          {
            containerPort: 8080,
            hostPort: 8080,
          },
        ],
        volumeMounts: [
          {
            mountPath: '/models/',
            name: 'models',
          },
        ],
      },
    ],
    volumes: [
      {
        name: 'models',
        hostPath: {
          path: './models/',
          type: 'Directory',
        },
      },
    ],
  },
}
