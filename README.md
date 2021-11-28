# Triple Banana Filter

This is a subresource filter list for third-party browsers. This is forked from
[**Bromite filters**](https://github.com/bromite/filters), and fixes some web
site broken issues.

## Why fork rather than contributing to the Bromite?
 - To reduce data usage, we'd like to serve the filter list in compressed form.
 - We'd like to serve the filter list to third-party browsers with **different
   release cycle and policy** than Bromite.

## Make indexed css filter
```
1. wget https://easylist.to/easylist/easylist.txt
2. ruleset_converter --input_format=filter-list --output_format=unindexed-ruleset --input_files=easylist.txt --output_file=easylist_unindexed
3. subresource_indexing_tool easylist_unindexed easylist_indexed

```

## License
GPL 3.0 (follows Bromite project)
