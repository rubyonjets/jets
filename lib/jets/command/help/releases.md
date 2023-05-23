## Examples

    $ jets releases
    Releases for stack: demo-dev
    +---------+-----------------+--------------+---------+
    | Version |     Status      | Released At  | Message |
    +---------+-----------------+--------------+---------+
    | 27      | UPDATE_COMPLETE | 10 hours ago | Deploy  |
    | 26      | UPDATE_COMPLETE | 11 hours ago | Deploy  |
    | 25      | UPDATE_COMPLETE | 11 hours ago | Deploy  |
    | 24      | UPDATE_COMPLETE | 11 hours ago | Deploy  |
    | 23      | DELETE_COMPLETE | 14 hours ago | Deleted |
    | 22      | UPDATE_COMPLETE | 14 hours ago | Deploy  |
    | 21      | UPDATE_COMPLETE | 14 hours ago | Deploy  |
    | 20      | UPDATE_COMPLETE | 14 hours ago | Deploy  |
    | 19      | DELETE_COMPLETE | 14 hours ago | Deleted |
    | 18      | UPDATE_COMPLETE | 14 hours ago | Deploy  |
    | 17      | UPDATE_COMPLETE | 17 hours ago | Deploy  |
    | 16      | UPDATE_COMPLETE | 18 hours ago | Deploy  |
    | 15      | UPDATE_COMPLETE | 18 hours ago | Deploy  |
    | 14      | DELETE_COMPLETE | 18 hours ago | Deleted |
    | 13      | UPDATE_COMPLETE | 19 hours ago | Deploy  |
    | 12      | UPDATE_COMPLETE | 19 hours ago | Deploy  |
    | 11      | UPDATE_COMPLETE | 19 hours ago | Deploy  |
    | 10      | DELETE_COMPLETE | 19 hours ago | Deleted |
    | 9       | UPDATE_COMPLETE | 21 hours ago | Deploy  |
    | 8       | UPDATE_COMPLETE | 21 hours ago | Deploy  |
    | 7       | DELETE_COMPLETE | 21 hours ago | Deleted |
    | 6       | UPDATE_COMPLETE | 21 hours ago | Deploy  |
    | 5       | DELETE_COMPLETE | 22 hours ago | Deleted |
    | 4       | UPDATE_COMPLETE | 22 hours ago | Deploy  |
    | 3       | UPDATE_COMPLETE | 22 hours ago | Deploy  |
    +---------+-----------------+--------------+---------+

The shown releases are paginated. If you need to see more releases you can use the `--page` option.

    $ jets releases --page 2
