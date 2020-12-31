# Marvin, a load test tool implemented in Elixir

## Setup

1. Install Elixir

```script
$ brew install elixir
```

2. Download the executable `marvin` at the project root

3. Create a config file

```json
// example_config.json

{
  "duration": 5,
  "scenarios": [
    {
      "name": "test", // to be used to identify workers
      "concurrency": 3,
      "endpoint": {
        "url": "http://localhost:3000",
        "method": "get"
      }
    }
  ]
}
```

4. Run the executable 

```script
# Start the load test
./marvin /path/to/config/file
```

\* If you want to build the latest executable, you can run

```script
mix deps.get
mix escript.build
```



## Marvin

In case you just came upon this project and is wondering why Marvin, instead of a more SEO-friendly project name: Marvin is the [Marvin from The Hitchhiker's Guide to the Galaxy](https://en.wikipedia.org/wiki/Marvin_the_Paranoid_Android). Go read it if you haven't already.



## Contributing

This is initially an internal project at PicCollage. Recently we had some time to make an open-source version of it–but just enough time to make it so. This is the MVP, there are obviously much room for improvement. If you are intrigued or if you like Elixir or if you find any bugs (I guarantee you will), please fix it yourself (yup) AND/OR let us know! 



## TODOs (unordered)

- [ ] [Test] Write them
- [ ] [Doc] Structure overview
- [ ] [Feat] Use Telemetry
- [ ] [Feat] Report intermediate results at intervals besides at the end
- [ ] [Feat] Better error handling
- [ ] [Feat] Print relevant system information at the start of program
- [ ] [Fix] Enforce metrics reporting before workers shutdown