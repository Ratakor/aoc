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
