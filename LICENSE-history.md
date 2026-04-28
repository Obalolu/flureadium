# License History

This file documents the licensing history of Flureadium and its upstream
project, `Notalib/flutter_readium`, for public reference.

## Summary

Flureadium is a fork of `Notalib/flutter_readium` taken at commit
[`ad9bc933a55edb072c193ef18e7d53e2b57c17e4`](https://github.com/Notalib/flutter_readium/commit/ad9bc933a55edb072c193ef18e7d53e2b57c17e4)
(2026-01-30). At that commit,
the upstream repository was published under the **GNU Lesser General Public
License, Version 3 (LGPL-3.0)**. Flureadium preserves that license
unchanged. The LICENSE file in this repository is byte-identical to the
upstream LICENSE at the fork point.

## Upstream LICENSE timeline

The licensing history of `Notalib/flutter_readium` up to and including the
fork point:

| Date         | Commit                                                                                                | Path                       | Action                                         |
|--------------|-------------------------------------------------------------------------------------------------------|----------------------------|------------------------------------------------|
| 2025-03-18   | [`e5151b72`](https://github.com/Notalib/flutter_readium/commit/e5151b72)                              | `LICENSE`                  | Created — placeholder text ("TODO: Add ...")   |
| 2025-04-25   | [`c0caf652`](https://github.com/Notalib/flutter_readium/commit/c0caf652)                              | `LICENSE`                  | Replaced with full LGPL-3.0 text               |
| 2025-04-30   | [`ec5e5927`](https://github.com/Notalib/flutter_readium/commit/ec5e5927)                              | `flutter_readium/LICENSE`  | Moved to plugin subdirectory (LGPL-3.0)        |
| **2026-01-30** | [**`ad9bc933`**](https://github.com/Notalib/flutter_readium/commit/ad9bc933a55edb072c193ef18e7d53e2b57c17e4) | (fork point)         | **No LICENSE change at this commit**           |

The LGPL-3.0 LICENSE file was therefore continuously published in the
upstream repository for **9 months and 5 days** prior to the fork.

Canonical content-addressed URL of the LICENSE at the fork point:

  https://github.com/Notalib/flutter_readium/blob/ad9bc933a55edb072c193ef18e7d53e2b57c17e4/flutter_readium/LICENSE

## Flureadium

- First Flureadium-specific commit:
  [`eed4bf51c24a27daea5d4e0ae71b284554d6a703`](https://github.com/mulev/flureadium/commit/eed4bf51c24a27daea5d4e0ae71b284554d6a703),
  dated 2026-01-31. Its parent is
  [`ad9bc933`](https://github.com/Notalib/flutter_readium/commit/ad9bc933a55edb072c193ef18e7d53e2b57c17e4)
  (the fork point).
- Flureadium's `LICENSE` and `LICENSE.md` contain the unmodified LGPL-3.0
  text. They are byte-identical (SHA-256
  `e3a994d82e644b03a792a930f574002658412f62407f5fee083f2555c5f23118`)
  to the upstream
  [`flutter_readium/LICENSE` at commit `ad9bc933`](https://github.com/Notalib/flutter_readium/blob/ad9bc933a55edb072c193ef18e7d53e2b57c17e4/flutter_readium/LICENSE).
- Attribution to the upstream project is preserved in the README and in
  the `NOTICE` file at the repository root.

## Verification

Anyone can independently verify the timeline:

```sh
# License content at the fork point (requires gh CLI)
gh api "repos/Notalib/flutter_readium/contents/flutter_readium/LICENSE?ref=ad9bc933a55edb072c193ef18e7d53e2b57c17e4" \
  --jq '.content' | base64 -d

# License history via the GitHub API
gh api "repos/Notalib/flutter_readium/commits?path=LICENSE&per_page=20" \
  --jq '.[] | {sha: .sha[0:8], date: .commit.author.date, msg: (.commit.message | split("\n")[0])}'
```

## License of Flureadium

Flureadium is, and remains, licensed under **LGPL-3.0**. See the `LICENSE`
file in this repository.
