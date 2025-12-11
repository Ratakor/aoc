let%expect_test "Day 01" =
  let input = "L68\nL30\nR48\nL5\nR60\nL55\nL1\nL99\nR14\nL82" in
  Printf.printf "%d" @@ Day01.part1 input;
  [%expect {| 3 |}];
  Printf.printf "%d" @@ Day01.part2 input;
  [%expect {| 6 |}]

let%expect_test "Day 02" =
  let input =
    "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124"
  in
  Printf.printf "%d" @@ Day02.part1 input;
  [%expect {| 1227775554 |}];
  Printf.printf "%d" @@ Day02.part2 input;
  [%expect {| 4174379265 |}]

let%expect_test "Day 03" =
  let input =
    "987654321111111\n811111111111119\n234234234234278\n818181911112111"
  in
  Printf.printf "%d" @@ Day03.part1 input;
  [%expect {| 357 |}];
  Printf.printf "%d" @@ Day03.part2 input;
  [%expect {| 3121910778619 |}]

let%expect_test "Day 04" =
  let input =
    {|..@@.@@@@.
@@@.@.@.@@
@@@@@.@.@@
@.@@@@..@.
@@.@@@@.@@
.@@@@@@@.@
.@.@.@.@@@
@.@@@.@@@@
.@@@@@@@@.
@.@.@@@.@.|}
  in
  Printf.printf "%d" @@ Day04.part1 input;
  [%expect {| 13 |}];
  Printf.printf "%d" @@ Day04.part2 input;
  [%expect {| 43 |}]

let%expect_test "Day 05" =
  let input = "3-5\n10-14\n16-20\n12-18\n\n1\n5\n8\n11\n17\n32" in
  Printf.printf "%d" @@ Day05.part1 input;
  [%expect {| 3 |}];
  Printf.printf "%d" @@ Day05.part2 input;
  [%expect {| 14 |}]

let%expect_test "Day 06" =
  let input = {|123 328  51 64
 45 64  387 23
  6 98  215 314
*   +   *   +|} in
  Printf.printf "%d" @@ Day06.part1 input;
  [%expect {| 4277556 |}];
  Printf.printf "%d" @@ Day06.part2 input;
  [%expect {| 3263827 |}]

let%expect_test "Day 07" =
  let input =
    {|.......S.......
...............
.......^.......
...............
......^.^......
...............
.....^.^.^.....
...............
....^.^...^....
...............
...^.^...^.^...
...............
..^...^.....^..
...............
.^.^.^.^.^...^.
...............|}
  in
  Printf.printf "%d" @@ Day07.part1 input;
  [%expect {| 21 |}];
  Printf.printf "%d" @@ Day07.part2 input;
  [%expect {| 40 |}]

let%expect_test "Day 08" =
  let input =
    {|162,817,812
57,618,57
906,360,560
592,479,940
352,342,300
466,668,158
542,29,236
431,825,988
739,650,466
52,470,668
216,146,977
819,987,18
117,168,530
805,96,715
346,949,466
970,615,88
941,993,340
862,61,35
984,92,344
425,690,689|}
  in
  Printf.printf "%d" @@ Day08.part1 input;
  [%expect {| 40 |}];
  Printf.printf "%d" @@ Day08.part2 input;
  [%expect {| 25272 |}]

let%expect_test "Day 09" =
  let input = {|7,1
11,1
11,7
9,7
9,5
2,5
2,3
7,3|} in
  Printf.printf "%d" @@ Day09.part1 input;
  [%expect {| 50 |}];
  Printf.printf "%d" @@ Day09.part2 input;
  [%expect {| 24 |}]

let%expect_test "Day 10" =
  let input =
    {|[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}
[...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}
[.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}|}
  in
  Printf.printf "%d" @@ Day10.part1 input;
  [%expect {| 7 |}];
  Printf.printf "%d" @@ Day10.part2 input;
  [%expect {| 33 |}]

let%expect_test "Day 11" =
  let input =
    {|aaa: you hhh
you: bbb ccc
bbb: ddd eee
ccc: ddd eee fff
ddd: ggg
eee: out
fff: out
ggg: out
hhh: ccc fff iii
iii: out|}
  in
  Printf.printf "%d" @@ Day11.part1 input;
  [%expect {| 5 |}];
  let input =
    {|svr: aaa bbb
aaa: fft
fft: ccc
bbb: tty
tty: ccc
ccc: ddd eee
ddd: hub
hub: fff
eee: dac
dac: fff
fff: ggg hhh
ggg: out
hhh: out|}
  in
  Printf.printf "%d" @@ Day11.part2 input;
  [%expect {| 2 |}]
