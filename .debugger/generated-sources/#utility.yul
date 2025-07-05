// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

library Utility

    function allocate_unbounded() {
        memPtr := mload(64)
    }
    function revert_error_dbdddcbe895c83990c08b3492a0e83918d802a52331272ac6fdb6a7c4aea3b1b() {
        revert(0, 0)
    }

    function revert_error_c1322bf8034eace5e0b5c7295db60986aa89aae5e0ea0873e4689e076861a5db() {
        revert(0, 0)
    }

    function cleanup_t_int256(value) -> cleaned {
        cleaned := value
    }

    function validator_revert_t_int256(value) {
        if iszero(eq(value, cleanup_t_int256(value))) { revert(0, 0) }
    }

    function abi_decode_t_int256(offset, end) -> value {
        value := calldataload(offset)
        validator_revert_t_int256(value)
    }

    function cleanup_t_uint256(value) -> cleaned {
        cleaned := value
    }

    function validator_revert_t_uint256(value) {
        if iszero(eq(value, cleanup_t_uint256(value))) { revert(0, 0) }
    }

    function abi_decode_t_uint256(offset, end) -> value {
        value := calldataload(offset)
        validator_revert_t_uint256(value)
    }

    function revert_error_1b9f4a0a5773e33b91aa01db23bf8c55fce1411167c872835e7fa00a4f17d46d() {
        revert(0, 0)
    }

    function revert_error_987264b3b1d58a9c7f8255e93e81c77d86d6299019c33110a076957a3e06e2ae() {
        revert(0, 0)
    }

    function round_up_to_mul_of_32(value) -> result {
        result := and(add(value, 31), not(31))
    }

    function panic_error_0x41() {
        mstore(0, 35408467139433450592217433187231851964531694900788300625387963629091585785856)
        mstore(4, 0x41)
        revert(0, 0x24)
    }

    function finalize_allocation(memPtr, size) {
        let newFreePtr := add(memPtr, round_up_to_mul_of_32(size))
        // protect against overflow
        if or(gt(newFreePtr, 0xffffffffffffffff), lt(newFreePtr, memPtr)) { panic_error_0x41() }
        mstore(64, newFreePtr)
    }

    function allocate_memory(size) -> memPtr {
        memPtr := allocate_unbounded()
        finalize_allocation(memPtr, size)
    }

    function array_allocation_size_t_string_memory_ptr(length) -> size {
        // Make sure we can allocate memory without overflow
        if gt(length, 0xffffffffffffffff) { panic_error_0x41() }

        size := round_up_to_mul_of_32(length)

        // add length slot
        size := add(size, 0x20)

    }

    function copy_calldata_to_memory_with_cleanup(src, dst, length) {
        calldatacopy(dst, src, length)
        mstore(add(dst, length), 0)
    }

    function abi_decode_available_length_t_string_memory_ptr(src, length, end) -> array {
        array := allocate_memory(array_allocation_size_t_string_memory_ptr(length))
        mstore(array, length)
        let dst := add(array, 0x20)
        if gt(add(src, length), end) { revert_error_987264b3b1d58a9c7f8255e93e81c77d86d6299019c33110a076957a3e06e2ae() }
        copy_calldata_to_memory_with_cleanup(src, dst, length)
    }

    // string
    function abi_decode_t_string_memory_ptr(offset, end) -> array {
        if iszero(slt(add(offset, 0x1f), end)) { revert_error_1b9f4a0a5773e33b91aa01db23bf8c55fce1411167c872835e7fa00a4f17d46d() }
        let length := calldataload(offset)
        array := abi_decode_available_length_t_string_memory_ptr(add(offset, 0x20), length, end)
    }

    function abi_decode_tuple_t_int256t_uint256t_string_memory_ptr(headStart, dataEnd) -> value0, value1, value2 {
        if slt(sub(dataEnd, headStart), 96) { revert_error_dbdddcbe895c83990c08b3492a0e83918d802a52331272ac6fdb6a7c4aea3b1b() }

        {

            let offset := 0

            value0 := abi_decode_t_int256(add(headStart, offset), dataEnd)
        }

        {

            let offset := 32

            value1 := abi_decode_t_uint256(add(headStart, offset), dataEnd)
        }

        {

            let offset := calldataload(add(headStart, 64))
            if gt(offset, 0xffffffffffffffff) { revert_error_c1322bf8034eace5e0b5c7295db60986aa89aae5e0ea0873e4689e076861a5db() }

            value2 := abi_decode_t_string_memory_ptr(add(headStart, offset), dataEnd)
        }

    }

    function cleanup_t_bool(value) -> cleaned {
        cleaned := iszero(iszero(value))
    }

    function abi_encode_t_bool_to_t_bool_fromStack_library(value, pos) {
        mstore(pos, cleanup_t_bool(value))
    }

    function abi_encode_tuple_t_bool__to_t_bool__fromStack_library_reversed(headStart , value0) -> tail {
        tail := add(headStart, 32)

        abi_encode_t_bool_to_t_bool_fromStack_library(value0,  add(headStart, 0))

    }

    function abi_decode_tuple_t_uint256t_int256t_string_memory_ptr(headStart, dataEnd) -> value0, value1, value2 {
        if slt(sub(dataEnd, headStart), 96) { revert_error_dbdddcbe895c83990c08b3492a0e83918d802a52331272ac6fdb6a7c4aea3b1b() }

        {

            let offset := 0

            value0 := abi_decode_t_uint256(add(headStart, offset), dataEnd)
        }

        {

            let offset := 32

            value1 := abi_decode_t_int256(add(headStart, offset), dataEnd)
        }

        {

            let offset := calldataload(add(headStart, 64))
            if gt(offset, 0xffffffffffffffff) { revert_error_c1322bf8034eace5e0b5c7295db60986aa89aae5e0ea0873e4689e076861a5db() }

            value2 := abi_decode_t_string_memory_ptr(add(headStart, offset), dataEnd)
        }

    }

    function validator_revert_t_bool(value) {
        if iszero(eq(value, cleanup_t_bool(value))) { revert(0, 0) }
    }

    function abi_decode_t_bool(offset, end) -> value {
        value := calldataload(offset)
        validator_revert_t_bool(value)
    }

    function abi_decode_tuple_t_boolt_string_memory_ptr(headStart, dataEnd) -> value0, value1 {
        if slt(sub(dataEnd, headStart), 64) { revert_error_dbdddcbe895c83990c08b3492a0e83918d802a52331272ac6fdb6a7c4aea3b1b() }

        {

            let offset := 0

            value0 := abi_decode_t_bool(add(headStart, offset), dataEnd)
        }

        {

            let offset := calldataload(add(headStart, 32))
            if gt(offset, 0xffffffffffffffff) { revert_error_c1322bf8034eace5e0b5c7295db60986aa89aae5e0ea0873e4689e076861a5db() }

            value1 := abi_decode_t_string_memory_ptr(add(headStart, offset), dataEnd)
        }

    }

    function abi_decode_tuple_t_boolt_boolt_string_memory_ptr(headStart, dataEnd) -> value0, value1, value2 {
        if slt(sub(dataEnd, headStart), 96) { revert_error_dbdddcbe895c83990c08b3492a0e83918d802a52331272ac6fdb6a7c4aea3b1b() }

        {

            let offset := 0

            value0 := abi_decode_t_bool(add(headStart, offset), dataEnd)
        }

        {

            let offset := 32

            value1 := abi_decode_t_bool(add(headStart, offset), dataEnd)
        }

        {

            let offset := calldataload(add(headStart, 64))
            if gt(offset, 0xffffffffffffffff) { revert_error_c1322bf8034eace5e0b5c7295db60986aa89aae5e0ea0873e4689e076861a5db() }

            value2 := abi_decode_t_string_memory_ptr(add(headStart, offset), dataEnd)
        }

    }

    function abi_decode_tuple_t_int256t_int256t_string_memory_ptr(headStart, dataEnd) -> value0, value1, value2 {
        if slt(sub(dataEnd, headStart), 96) { revert_error_dbdddcbe895c83990c08b3492a0e83918d802a52331272ac6fdb6a7c4aea3b1b() }

        {

            let offset := 0

            value0 := abi_decode_t_int256(add(headStart, offset), dataEnd)
        }

        {

            let offset := 32

            value1 := abi_decode_t_int256(add(headStart, offset), dataEnd)
        }

        {

            let offset := calldataload(add(headStart, 64))
            if gt(offset, 0xffffffffffffffff) { revert_error_c1322bf8034eace5e0b5c7295db60986aa89aae5e0ea0873e4689e076861a5db() }

            value2 := abi_decode_t_string_memory_ptr(add(headStart, offset), dataEnd)
        }

    }

    function abi_decode_tuple_t_string_memory_ptrt_string_memory_ptrt_string_memory_ptr(headStart, dataEnd) -> value0, value1, value2 {
        if slt(sub(dataEnd, headStart), 96) { revert_error_dbdddcbe895c83990c08b3492a0e83918d802a52331272ac6fdb6a7c4aea3b1b() }

        {

            let offset := calldataload(add(headStart, 0))
            if gt(offset, 0xffffffffffffffff) { revert_error_c1322bf8034eace5e0b5c7295db60986aa89aae5e0ea0873e4689e076861a5db() }

            value0 := abi_decode_t_string_memory_ptr(add(headStart, offset), dataEnd)
        }

        {

            let offset := calldataload(add(headStart, 32))
            if gt(offset, 0xffffffffffffffff) { revert_error_c1322bf8034eace5e0b5c7295db60986aa89aae5e0ea0873e4689e076861a5db() }

            value1 := abi_decode_t_string_memory_ptr(add(headStart, offset), dataEnd)
        }

        {

            let offset := calldataload(add(headStart, 64))
            if gt(offset, 0xffffffffffffffff) { revert_error_c1322bf8034eace5e0b5c7295db60986aa89aae5e0ea0873e4689e076861a5db() }

            value2 := abi_decode_t_string_memory_ptr(add(headStart, offset), dataEnd)
        }

    }

    function cleanup_t_bytes32(value) -> cleaned {
        cleaned := value
    }

    function validator_revert_t_bytes32(value) {
        if iszero(eq(value, cleanup_t_bytes32(value))) { revert(0, 0) }
    }

    function abi_decode_t_bytes32(offset, end) -> value {
        value := calldataload(offset)
        validator_revert_t_bytes32(value)
    }

    function abi_decode_tuple_t_bytes32t_bytes32t_string_memory_ptr(headStart, dataEnd) -> value0, value1, value2 {
        if slt(sub(dataEnd, headStart), 96) { revert_error_dbdddcbe895c83990c08b3492a0e83918d802a52331272ac6fdb6a7c4aea3b1b() }

        {

            let offset := 0

            value0 := abi_decode_t_bytes32(add(headStart, offset), dataEnd)
        }

        {

            let offset := 32

            value1 := abi_decode_t_bytes32(add(headStart, offset), dataEnd)
        }

        {

            let offset := calldataload(add(headStart, 64))
            if gt(offset, 0xffffffffffffffff) { revert_error_c1322bf8034eace5e0b5c7295db60986aa89aae5e0ea0873e4689e076861a5db() }

            value2 := abi_decode_t_string_memory_ptr(add(headStart, offset), dataEnd)
        }

    }

    function abi_decode_tuple_t_uint256t_uint256t_string_memory_ptr(headStart, dataEnd) -> value0, value1, value2 {
        if slt(sub(dataEnd, headStart), 96) { revert_error_dbdddcbe895c83990c08b3492a0e83918d802a52331272ac6fdb6a7c4aea3b1b() }

        {

            let offset := 0

            value0 := abi_decode_t_uint256(add(headStart, offset), dataEnd)
        }

        {

            let offset := 32

            value1 := abi_decode_t_uint256(add(headStart, offset), dataEnd)
        }

        {

            let offset := calldataload(add(headStart, 64))
            if gt(offset, 0xffffffffffffffff) { revert_error_c1322bf8034eace5e0b5c7295db60986aa89aae5e0ea0873e4689e076861a5db() }

            value2 := abi_decode_t_string_memory_ptr(add(headStart, offset), dataEnd)
        }

    }

    function cleanup_t_uint160(value) -> cleaned {
        cleaned := and(value, 0xffffffffffffffffffffffffffffffffffffffff)
    }

    function cleanup_t_address(value) -> cleaned {
        cleaned := cleanup_t_uint160(value)
    }

    function validator_revert_t_address(value) {
        if iszero(eq(value, cleanup_t_address(value))) { revert(0, 0) }
    }

    function abi_decode_t_address(offset, end) -> value {
        value := calldataload(offset)
        validator_revert_t_address(value)
    }

    function abi_decode_tuple_t_addresst_addresst_string_memory_ptr(headStart, dataEnd) -> value0, value1, value2 {
        if slt(sub(dataEnd, headStart), 96) { revert_error_dbdddcbe895c83990c08b3492a0e83918d802a52331272ac6fdb6a7c4aea3b1b() }

        {

            let offset := 0

            value0 := abi_decode_t_address(add(headStart, offset), dataEnd)
        }

        {

            let offset := 32

            value1 := abi_decode_t_address(add(headStart, offset), dataEnd)
        }

        {

            let offset := calldataload(add(headStart, 64))
            if gt(offset, 0xffffffffffffffff) { revert_error_c1322bf8034eace5e0b5c7295db60986aa89aae5e0ea0873e4689e076861a5db() }

            value2 := abi_decode_t_string_memory_ptr(add(headStart, offset), dataEnd)
        }

    }

    function abi_encode_t_bool_to_t_bool_fromStack(value, pos) {
        mstore(pos, cleanup_t_bool(value))
    }

    function array_length_t_string_memory_ptr(value) -> length {

        length := mload(value)

    }

    function array_storeLengthForEncoding_t_string_memory_ptr_fromStack(pos, length) -> updated_pos {
        mstore(pos, length)
        updated_pos := add(pos, 0x20)
    }

    function copy_memory_to_memory_with_cleanup(src, dst, length) {
        let i := 0
        for { } lt(i, length) { i := add(i, 32) }
        {
            mstore(add(dst, i), mload(add(src, i)))
        }
        mstore(add(dst, length), 0)
    }

    function abi_encode_t_string_memory_ptr_to_t_string_memory_ptr_fromStack(value, pos) -> end {
        let length := array_length_t_string_memory_ptr(value)
        pos := array_storeLengthForEncoding_t_string_memory_ptr_fromStack(pos, length)
        copy_memory_to_memory_with_cleanup(add(value, 0x20), pos, length)
        end := add(pos, round_up_to_mul_of_32(length))
    }

    function store_literal_in_memory_50a97f23c5119bdada150dd747dad0c52d0fcca899436a501c98e865f82ff03f(memPtr) {

        mstore(add(memPtr, 0), "greaterThan")

    }

    function abi_encode_t_stringliteral_50a97f23c5119bdada150dd747dad0c52d0fcca899436a501c98e865f82ff03f_to_t_string_memory_ptr_fromStack(pos) -> end {
        pos := array_storeLengthForEncoding_t_string_memory_ptr_fromStack(pos, 11)
        store_literal_in_memory_50a97f23c5119bdada150dd747dad0c52d0fcca899436a501c98e865f82ff03f(pos)
        end := add(pos, 32)
    }

    function abi_encode_t_int256_to_t_int256_fromStack(value, pos) {
        mstore(pos, cleanup_t_int256(value))
    }

    function abi_encode_t_uint256_to_t_uint256_fromStack(value, pos) {
        mstore(pos, cleanup_t_uint256(value))
    }

    function abi_encode_tuple_t_bool_t_string_memory_ptr_t_stringliteral_50a97f23c5119bdada150dd747dad0c52d0fcca899436a501c98e865f82ff03f_t_int256_t_uint256__to_t_bool_t_string_memory_ptr_t_string_memory_ptr_t_int256_t_uint256__fromStack_reversed(headStart , value3, value2, value1, value0) -> tail {
        tail := add(headStart, 160)

        abi_encode_t_bool_to_t_bool_fromStack(value0,  add(headStart, 0))

        mstore(add(headStart, 32), sub(tail, headStart))
        tail := abi_encode_t_string_memory_ptr_to_t_string_memory_ptr_fromStack(value1,  tail)

        mstore(add(headStart, 64), sub(tail, headStart))
        tail := abi_encode_t_stringliteral_50a97f23c5119bdada150dd747dad0c52d0fcca899436a501c98e865f82ff03f_to_t_string_memory_ptr_fromStack( tail)

        abi_encode_t_int256_to_t_int256_fromStack(value2,  add(headStart, 96))

        abi_encode_t_uint256_to_t_uint256_fromStack(value3,  add(headStart, 128))

    }

    function store_literal_in_memory_6eacbbc162a376a1056ee46defb5ad8c0513de0d938dbfce38c05fc663a8556d(memPtr) {

        mstore(add(memPtr, 0), "lesserThan")

    }

    function abi_encode_t_stringliteral_6eacbbc162a376a1056ee46defb5ad8c0513de0d938dbfce38c05fc663a8556d_to_t_string_memory_ptr_fromStack(pos) -> end {
        pos := array_storeLengthForEncoding_t_string_memory_ptr_fromStack(pos, 10)
        store_literal_in_memory_6eacbbc162a376a1056ee46defb5ad8c0513de0d938dbfce38c05fc663a8556d(pos)
        end := add(pos, 32)
    }

    function abi_encode_tuple_t_bool_t_string_memory_ptr_t_stringliteral_6eacbbc162a376a1056ee46defb5ad8c0513de0d938dbfce38c05fc663a8556d_t_uint256_t_int256__to_t_bool_t_string_memory_ptr_t_string_memory_ptr_t_uint256_t_int256__fromStack_reversed(headStart , value3, value2, value1, value0) -> tail {
        tail := add(headStart, 160)

        abi_encode_t_bool_to_t_bool_fromStack(value0,  add(headStart, 0))

        mstore(add(headStart, 32), sub(tail, headStart))
        tail := abi_encode_t_string_memory_ptr_to_t_string_memory_ptr_fromStack(value1,  tail)

        mstore(add(headStart, 64), sub(tail, headStart))
        tail := abi_encode_t_stringliteral_6eacbbc162a376a1056ee46defb5ad8c0513de0d938dbfce38c05fc663a8556d_to_t_string_memory_ptr_fromStack( tail)

        abi_encode_t_uint256_to_t_uint256_fromStack(value2,  add(headStart, 96))

        abi_encode_t_int256_to_t_int256_fromStack(value3,  add(headStart, 128))

    }

    function store_literal_in_memory_14502d3ab34ae28d404da8f6ec0501c6f295f66caa41e122cfa9b1291bc0f9e8(memPtr) {

        mstore(add(memPtr, 0), "ok")

    }

    function abi_encode_t_stringliteral_14502d3ab34ae28d404da8f6ec0501c6f295f66caa41e122cfa9b1291bc0f9e8_to_t_string_memory_ptr_fromStack(pos) -> end {
        pos := array_storeLengthForEncoding_t_string_memory_ptr_fromStack(pos, 2)
        store_literal_in_memory_14502d3ab34ae28d404da8f6ec0501c6f295f66caa41e122cfa9b1291bc0f9e8(pos)
        end := add(pos, 32)
    }

    function abi_encode_tuple_t_bool_t_string_memory_ptr_t_stringliteral_14502d3ab34ae28d404da8f6ec0501c6f295f66caa41e122cfa9b1291bc0f9e8__to_t_bool_t_string_memory_ptr_t_string_memory_ptr__fromStack_reversed(headStart , value1, value0) -> tail {
        tail := add(headStart, 96)

        abi_encode_t_bool_to_t_bool_fromStack(value0,  add(headStart, 0))

        mstore(add(headStart, 32), sub(tail, headStart))
        tail := abi_encode_t_string_memory_ptr_to_t_string_memory_ptr_fromStack(value1,  tail)

        mstore(add(headStart, 64), sub(tail, headStart))
        tail := abi_encode_t_stringliteral_14502d3ab34ae28d404da8f6ec0501c6f295f66caa41e122cfa9b1291bc0f9e8_to_t_string_memory_ptr_fromStack( tail)

    }

    function store_literal_in_memory_9221cc5593ebbd03a3c08e5d1bf5bfda46e44ce5d969a4cf46cd32ca4bbd45ce(memPtr) {

        mstore(add(memPtr, 0), "notEqual")

    }

    function abi_encode_t_stringliteral_9221cc5593ebbd03a3c08e5d1bf5bfda46e44ce5d969a4cf46cd32ca4bbd45ce_to_t_string_memory_ptr_fromStack(pos) -> end {
        pos := array_storeLengthForEncoding_t_string_memory_ptr_fromStack(pos, 8)
        store_literal_in_memory_9221cc5593ebbd03a3c08e5d1bf5bfda46e44ce5d969a4cf46cd32ca4bbd45ce(pos)
        end := add(pos, 32)
    }

    function abi_encode_tuple_t_bool_t_string_memory_ptr_t_stringliteral_9221cc5593ebbd03a3c08e5d1bf5bfda46e44ce5d969a4cf46cd32ca4bbd45ce_t_bool_t_bool__to_t_bool_t_string_memory_ptr_t_string_memory_ptr_t_bool_t_bool__fromStack_reversed(headStart , value3, value2, value1, value0) -> tail {
        tail := add(headStart, 160)

        abi_encode_t_bool_to_t_bool_fromStack(value0,  add(headStart, 0))

        mstore(add(headStart, 32), sub(tail, headStart))
        tail := abi_encode_t_string_memory_ptr_to_t_string_memory_ptr_fromStack(value1,  tail)

        mstore(add(headStart, 64), sub(tail, headStart))
        tail := abi_encode_t_stringliteral_9221cc5593ebbd03a3c08e5d1bf5bfda46e44ce5d969a4cf46cd32ca4bbd45ce_to_t_string_memory_ptr_fromStack( tail)

        abi_encode_t_bool_to_t_bool_fromStack(value2,  add(headStart, 96))

        abi_encode_t_bool_to_t_bool_fromStack(value3,  add(headStart, 128))

    }

    function abi_encode_tuple_t_bool_t_string_memory_ptr_t_stringliteral_6eacbbc162a376a1056ee46defb5ad8c0513de0d938dbfce38c05fc663a8556d_t_int256_t_int256__to_t_bool_t_string_memory_ptr_t_string_memory_ptr_t_int256_t_int256__fromStack_reversed(headStart , value3, value2, value1, value0) -> tail {
        tail := add(headStart, 160)

        abi_encode_t_bool_to_t_bool_fromStack(value0,  add(headStart, 0))

        mstore(add(headStart, 32), sub(tail, headStart))
        tail := abi_encode_t_string_memory_ptr_to_t_string_memory_ptr_fromStack(value1,  tail)

        mstore(add(headStart, 64), sub(tail, headStart))
        tail := abi_encode_t_stringliteral_6eacbbc162a376a1056ee46defb5ad8c0513de0d938dbfce38c05fc663a8556d_to_t_string_memory_ptr_fromStack( tail)

        abi_encode_t_int256_to_t_int256_fromStack(value2,  add(headStart, 96))

        abi_encode_t_int256_to_t_int256_fromStack(value3,  add(headStart, 128))

    }

    function array_storeLengthForEncoding_t_string_memory_ptr_nonPadded_inplace_fromStack(pos, length) -> updated_pos {
        updated_pos := pos
    }

    function abi_encode_t_string_memory_ptr_to_t_string_memory_ptr_nonPadded_inplace_fromStack(value, pos) -> end {
        let length := array_length_t_string_memory_ptr(value)
        pos := array_storeLengthForEncoding_t_string_memory_ptr_nonPadded_inplace_fromStack(pos, length)
        copy_memory_to_memory_with_cleanup(add(value, 0x20), pos, length)
        end := add(pos, length)
    }

    function abi_encode_tuple_packed_t_string_memory_ptr__to_t_string_memory_ptr__nonPadded_inplace_fromStack_reversed(pos , value0) -> end {

        pos := abi_encode_t_string_memory_ptr_to_t_string_memory_ptr_nonPadded_inplace_fromStack(value0,  pos)

        end := pos
    }

    function abi_encode_tuple_t_bool_t_string_memory_ptr_t_stringliteral_9221cc5593ebbd03a3c08e5d1bf5bfda46e44ce5d969a4cf46cd32ca4bbd45ce_t_string_memory_ptr_t_string_memory_ptr__to_t_bool_t_string_memory_ptr_t_string_memory_ptr_t_string_memory_ptr_t_string_memory_ptr__fromStack_reversed(headStart , value3, value2, value1, value0) -> tail {
        tail := add(headStart, 160)

        abi_encode_t_bool_to_t_bool_fromStack(value0,  add(headStart, 0))

        mstore(add(headStart, 32), sub(tail, headStart))
        tail := abi_encode_t_string_memory_ptr_to_t_string_memory_ptr_fromStack(value1,  tail)

        mstore(add(headStart, 64), sub(tail, headStart))
        tail := abi_encode_t_stringliteral_9221cc5593ebbd03a3c08e5d1bf5bfda46e44ce5d969a4cf46cd32ca4bbd45ce_to_t_string_memory_ptr_fromStack( tail)

        mstore(add(headStart, 96), sub(tail, headStart))
        tail := abi_encode_t_string_memory_ptr_to_t_string_memory_ptr_fromStack(value2,  tail)

        mstore(add(headStart, 128), sub(tail, headStart))
        tail := abi_encode_t_string_memory_ptr_to_t_string_memory_ptr_fromStack(value3,  tail)

    }

    function abi_encode_tuple_t_bool_t_string_memory_ptr_t_stringliteral_9221cc5593ebbd03a3c08e5d1bf5bfda46e44ce5d969a4cf46cd32ca4bbd45ce_t_int256_t_int256__to_t_bool_t_string_memory_ptr_t_string_memory_ptr_t_int256_t_int256__fromStack_reversed(headStart , value3, value2, value1, value0) -> tail {
        tail := add(headStart, 160)

        abi_encode_t_bool_to_t_bool_fromStack(value0,  add(headStart, 0))

        mstore(add(headStart, 32), sub(tail, headStart))
        tail := abi_encode_t_string_memory_ptr_to_t_string_memory_ptr_fromStack(value1,  tail)

        mstore(add(headStart, 64), sub(tail, headStart))
        tail := abi_encode_t_stringliteral_9221cc5593ebbd03a3c08e5d1bf5bfda46e44ce5d969a4cf46cd32ca4bbd45ce_to_t_string_memory_ptr_fromStack( tail)

        abi_encode_t_int256_to_t_int256_fromStack(value2,  add(headStart, 96))

        abi_encode_t_int256_to_t_int256_fromStack(value3,  add(headStart, 128))

    }

    function abi_encode_t_bytes32_to_t_bytes32_fromStack(value, pos) {
        mstore(pos, cleanup_t_bytes32(value))
    }

    function abi_encode_tuple_t_bool_t_string_memory_ptr_t_stringliteral_9221cc5593ebbd03a3c08e5d1bf5bfda46e44ce5d969a4cf46cd32ca4bbd45ce_t_bytes32_t_bytes32__to_t_bool_t_string_memory_ptr_t_string_memory_ptr_t_bytes32_t_bytes32__fromStack_reversed(headStart , value3, value2, value1, value0) -> tail {
        tail := add(headStart, 160)

        abi_encode_t_bool_to_t_bool_fromStack(value0,  add(headStart, 0))

        mstore(add(headStart, 32), sub(tail, headStart))
        tail := abi_encode_t_string_memory_ptr_to_t_string_memory_ptr_fromStack(value1,  tail)

        mstore(add(headStart, 64), sub(tail, headStart))
        tail := abi_encode_t_stringliteral_9221cc5593ebbd03a3c08e5d1bf5bfda46e44ce5d969a4cf46cd32ca4bbd45ce_to_t_string_memory_ptr_fromStack( tail)

        abi_encode_t_bytes32_to_t_bytes32_fromStack(value2,  add(headStart, 96))

        abi_encode_t_bytes32_to_t_bytes32_fromStack(value3,  add(headStart, 128))

    }

    function abi_encode_tuple_t_bool_t_string_memory_ptr_t_stringliteral_9221cc5593ebbd03a3c08e5d1bf5bfda46e44ce5d969a4cf46cd32ca4bbd45ce_t_uint256_t_uint256__to_t_bool_t_string_memory_ptr_t_string_memory_ptr_t_uint256_t_uint256__fromStack_reversed(headStart , value3, value2, value1, value0) -> tail {
        tail := add(headStart, 160)

        abi_encode_t_bool_to_t_bool_fromStack(value0,  add(headStart, 0))

        mstore(add(headStart, 32), sub(tail, headStart))
        tail := abi_encode_t_string_memory_ptr_to_t_string_memory_ptr_fromStack(value1,  tail)

        mstore(add(headStart, 64), sub(tail, headStart))
        tail := abi_encode_t_stringliteral_9221cc5593ebbd03a3c08e5d1bf5bfda46e44ce5d969a4cf46cd32ca4bbd45ce_to_t_string_memory_ptr_fromStack( tail)

        abi_encode_t_uint256_to_t_uint256_fromStack(value2,  add(headStart, 96))

        abi_encode_t_uint256_to_t_uint256_fromStack(value3,  add(headStart, 128))

    }

    function store_literal_in_memory_2602ee1ebf372b25bffbd066c8358edb7f611f67d29a83d531f51d21a4ab2e89(memPtr) {

        mstore(add(memPtr, 0), "equal")

    }

    function abi_encode_t_stringliteral_2602ee1ebf372b25bffbd066c8358edb7f611f67d29a83d531f51d21a4ab2e89_to_t_string_memory_ptr_fromStack(pos) -> end {
        pos := array_storeLengthForEncoding_t_string_memory_ptr_fromStack(pos, 5)
        store_literal_in_memory_2602ee1ebf372b25bffbd066c8358edb7f611f67d29a83d531f51d21a4ab2e89(pos)
        end := add(pos, 32)
    }

    function abi_encode_tuple_t_bool_t_string_memory_ptr_t_stringliteral_2602ee1ebf372b25bffbd066c8358edb7f611f67d29a83d531f51d21a4ab2e89_t_bool_t_bool__to_t_bool_t_string_memory_ptr_t_string_memory_ptr_t_bool_t_bool__fromStack_reversed(headStart , value3, value2, value1, value0) -> tail {
        tail := add(headStart, 160)

        abi_encode_t_bool_to_t_bool_fromStack(value0,  add(headStart, 0))

        mstore(add(headStart, 32), sub(tail, headStart))
        tail := abi_encode_t_string_memory_ptr_to_t_string_memory_ptr_fromStack(value1,  tail)

        mstore(add(headStart, 64), sub(tail, headStart))
        tail := abi_encode_t_stringliteral_2602ee1ebf372b25bffbd066c8358edb7f611f67d29a83d531f51d21a4ab2e89_to_t_string_memory_ptr_fromStack( tail)

        abi_encode_t_bool_to_t_bool_fromStack(value2,  add(headStart, 96))

        abi_encode_t_bool_to_t_bool_fromStack(value3,  add(headStart, 128))

    }

    function abi_encode_tuple_t_bool_t_string_memory_ptr_t_stringliteral_6eacbbc162a376a1056ee46defb5ad8c0513de0d938dbfce38c05fc663a8556d_t_int256_t_uint256__to_t_bool_t_string_memory_ptr_t_string_memory_ptr_t_int256_t_uint256__fromStack_reversed(headStart , value3, value2, value1, value0) -> tail {
        tail := add(headStart, 160)

        abi_encode_t_bool_to_t_bool_fromStack(value0,  add(headStart, 0))

        mstore(add(headStart, 32), sub(tail, headStart))
        tail := abi_encode_t_string_memory_ptr_to_t_string_memory_ptr_fromStack(value1,  tail)

        mstore(add(headStart, 64), sub(tail, headStart))
        tail := abi_encode_t_stringliteral_6eacbbc162a376a1056ee46defb5ad8c0513de0d938dbfce38c05fc663a8556d_to_t_string_memory_ptr_fromStack( tail)

        abi_encode_t_int256_to_t_int256_fromStack(value2,  add(headStart, 96))

        abi_encode_t_uint256_to_t_uint256_fromStack(value3,  add(headStart, 128))

    }

    function abi_encode_tuple_t_bool_t_string_memory_ptr_t_stringliteral_50a97f23c5119bdada150dd747dad0c52d0fcca899436a501c98e865f82ff03f_t_uint256_t_int256__to_t_bool_t_string_memory_ptr_t_string_memory_ptr_t_uint256_t_int256__fromStack_reversed(headStart , value3, value2, value1, value0) -> tail {
        tail := add(headStart, 160)

        abi_encode_t_bool_to_t_bool_fromStack(value0,  add(headStart, 0))

        mstore(add(headStart, 32), sub(tail, headStart))
        tail := abi_encode_t_string_memory_ptr_to_t_string_memory_ptr_fromStack(value1,  tail)

        mstore(add(headStart, 64), sub(tail, headStart))
        tail := abi_encode_t_stringliteral_50a97f23c5119bdada150dd747dad0c52d0fcca899436a501c98e865f82ff03f_to_t_string_memory_ptr_fromStack( tail)

        abi_encode_t_uint256_to_t_uint256_fromStack(value2,  add(headStart, 96))

        abi_encode_t_int256_to_t_int256_fromStack(value3,  add(headStart, 128))

    }

    function abi_encode_tuple_t_bool_t_string_memory_ptr_t_stringliteral_50a97f23c5119bdada150dd747dad0c52d0fcca899436a501c98e865f82ff03f_t_int256_t_int256__to_t_bool_t_string_memory_ptr_t_string_memory_ptr_t_int256_t_int256__fromStack_reversed(headStart , value3, value2, value1, value0) -> tail {
        tail := add(headStart, 160)

        abi_encode_t_bool_to_t_bool_fromStack(value0,  add(headStart, 0))

        mstore(add(headStart, 32), sub(tail, headStart))
        tail := abi_encode_t_string_memory_ptr_to_t_string_memory_ptr_fromStack(value1,  tail)

        mstore(add(headStart, 64), sub(tail, headStart))
        tail := abi_encode_t_stringliteral_50a97f23c5119bdada150dd747dad0c52d0fcca899436a501c98e865f82ff03f_to_t_string_memory_ptr_fromStack( tail)

        abi_encode_t_int256_to_t_int256_fromStack(value2,  add(headStart, 96))

        abi_encode_t_int256_to_t_int256_fromStack(value3,  add(headStart, 128))

    }

    function abi_encode_tuple_t_bool_t_string_memory_ptr_t_stringliteral_50a97f23c5119bdada150dd747dad0c52d0fcca899436a501c98e865f82ff03f_t_uint256_t_uint256__to_t_bool_t_string_memory_ptr_t_string_memory_ptr_t_uint256_t_uint256__fromStack_reversed(headStart , value3, value2, value1, value0) -> tail {
        tail := add(headStart, 160)

        abi_encode_t_bool_to_t_bool_fromStack(value0,  add(headStart, 0))

        mstore(add(headStart, 32), sub(tail, headStart))
        tail := abi_encode_t_string_memory_ptr_to_t_string_memory_ptr_fromStack(value1,  tail)

        mstore(add(headStart, 64), sub(tail, headStart))
        tail := abi_encode_t_stringliteral_50a97f23c5119bdada150dd747dad0c52d0fcca899436a501c98e865f82ff03f_to_t_string_memory_ptr_fromStack( tail)

        abi_encode_t_uint256_to_t_uint256_fromStack(value2,  add(headStart, 96))

        abi_encode_t_uint256_to_t_uint256_fromStack(value3,  add(headStart, 128))

    }

    function abi_encode_tuple_t_bool_t_string_memory_ptr_t_stringliteral_2602ee1ebf372b25bffbd066c8358edb7f611f67d29a83d531f51d21a4ab2e89_t_uint256_t_uint256__to_t_bool_t_string_memory_ptr_t_string_memory_ptr_t_uint256_t_uint256__fromStack_reversed(headStart , value3, value2, value1, value0) -> tail {
        tail := add(headStart, 160)

        abi_encode_t_bool_to_t_bool_fromStack(value0,  add(headStart, 0))

        mstore(add(headStart, 32), sub(tail, headStart))
        tail := abi_encode_t_string_memory_ptr_to_t_string_memory_ptr_fromStack(value1,  tail)

        mstore(add(headStart, 64), sub(tail, headStart))
        tail := abi_encode_t_stringliteral_2602ee1ebf372b25bffbd066c8358edb7f611f67d29a83d531f51d21a4ab2e89_to_t_string_memory_ptr_fromStack( tail)

        abi_encode_t_uint256_to_t_uint256_fromStack(value2,  add(headStart, 96))

        abi_encode_t_uint256_to_t_uint256_fromStack(value3,  add(headStart, 128))

    }

    function abi_encode_tuple_t_bool_t_string_memory_ptr_t_stringliteral_6eacbbc162a376a1056ee46defb5ad8c0513de0d938dbfce38c05fc663a8556d_t_uint256_t_uint256__to_t_bool_t_string_memory_ptr_t_string_memory_ptr_t_uint256_t_uint256__fromStack_reversed(headStart , value3, value2, value1, value0) -> tail {
        tail := add(headStart, 160)

        abi_encode_t_bool_to_t_bool_fromStack(value0,  add(headStart, 0))

        mstore(add(headStart, 32), sub(tail, headStart))
        tail := abi_encode_t_string_memory_ptr_to_t_string_memory_ptr_fromStack(value1,  tail)

        mstore(add(headStart, 64), sub(tail, headStart))
        tail := abi_encode_t_stringliteral_6eacbbc162a376a1056ee46defb5ad8c0513de0d938dbfce38c05fc663a8556d_to_t_string_memory_ptr_fromStack( tail)

        abi_encode_t_uint256_to_t_uint256_fromStack(value2,  add(headStart, 96))

        abi_encode_t_uint256_to_t_uint256_fromStack(value3,  add(headStart, 128))

    }

    function abi_encode_t_address_to_t_address_fromStack(value, pos) {
        mstore(pos, cleanup_t_address(value))
    }

    function abi_encode_tuple_t_bool_t_string_memory_ptr_t_stringliteral_9221cc5593ebbd03a3c08e5d1bf5bfda46e44ce5d969a4cf46cd32ca4bbd45ce_t_address_t_address__to_t_bool_t_string_memory_ptr_t_string_memory_ptr_t_address_t_address__fromStack_reversed(headStart , value3, value2, value1, value0) -> tail {
        tail := add(headStart, 160)

        abi_encode_t_bool_to_t_bool_fromStack(value0,  add(headStart, 0))

        mstore(add(headStart, 32), sub(tail, headStart))
        tail := abi_encode_t_string_memory_ptr_to_t_string_memory_ptr_fromStack(value1,  tail)

        mstore(add(headStart, 64), sub(tail, headStart))
        tail := abi_encode_t_stringliteral_9221cc5593ebbd03a3c08e5d1bf5bfda46e44ce5d969a4cf46cd32ca4bbd45ce_to_t_string_memory_ptr_fromStack( tail)

        abi_encode_t_address_to_t_address_fromStack(value2,  add(headStart, 96))

        abi_encode_t_address_to_t_address_fromStack(value3,  add(headStart, 128))

    }

    function abi_encode_tuple_t_bool_t_string_memory_ptr_t_stringliteral_2602ee1ebf372b25bffbd066c8358edb7f611f67d29a83d531f51d21a4ab2e89_t_address_t_address__to_t_bool_t_string_memory_ptr_t_string_memory_ptr_t_address_t_address__fromStack_reversed(headStart , value3, value2, value1, value0) -> tail {
        tail := add(headStart, 160)

        abi_encode_t_bool_to_t_bool_fromStack(value0,  add(headStart, 0))

        mstore(add(headStart, 32), sub(tail, headStart))
        tail := abi_encode_t_string_memory_ptr_to_t_string_memory_ptr_fromStack(value1,  tail)

        mstore(add(headStart, 64), sub(tail, headStart))
        tail := abi_encode_t_stringliteral_2602ee1ebf372b25bffbd066c8358edb7f611f67d29a83d531f51d21a4ab2e89_to_t_string_memory_ptr_fromStack( tail)

        abi_encode_t_address_to_t_address_fromStack(value2,  add(headStart, 96))

        abi_encode_t_address_to_t_address_fromStack(value3,  add(headStart, 128))

    }

    function abi_encode_tuple_t_bool_t_string_memory_ptr_t_stringliteral_2602ee1ebf372b25bffbd066c8358edb7f611f67d29a83d531f51d21a4ab2e89_t_string_memory_ptr_t_string_memory_ptr__to_t_bool_t_string_memory_ptr_t_string_memory_ptr_t_string_memory_ptr_t_string_memory_ptr__fromStack_reversed(headStart , value3, value2, value1, value0) -> tail {
        tail := add(headStart, 160)

        abi_encode_t_bool_to_t_bool_fromStack(value0,  add(headStart, 0))

        mstore(add(headStart, 32), sub(tail, headStart))
        tail := abi_encode_t_string_memory_ptr_to_t_string_memory_ptr_fromStack(value1,  tail)

        mstore(add(headStart, 64), sub(tail, headStart))
        tail := abi_encode_t_stringliteral_2602ee1ebf372b25bffbd066c8358edb7f611f67d29a83d531f51d21a4ab2e89_to_t_string_memory_ptr_fromStack( tail)

        mstore(add(headStart, 96), sub(tail, headStart))
        tail := abi_encode_t_string_memory_ptr_to_t_string_memory_ptr_fromStack(value2,  tail)

        mstore(add(headStart, 128), sub(tail, headStart))
        tail := abi_encode_t_string_memory_ptr_to_t_string_memory_ptr_fromStack(value3,  tail)

    }

    function abi_encode_tuple_t_bool_t_string_memory_ptr_t_stringliteral_2602ee1ebf372b25bffbd066c8358edb7f611f67d29a83d531f51d21a4ab2e89_t_bytes32_t_bytes32__to_t_bool_t_string_memory_ptr_t_string_memory_ptr_t_bytes32_t_bytes32__fromStack_reversed(headStart , value3, value2, value1, value0) -> tail {
        tail := add(headStart, 160)

        abi_encode_t_bool_to_t_bool_fromStack(value0,  add(headStart, 0))

        mstore(add(headStart, 32), sub(tail, headStart))
        tail := abi_encode_t_string_memory_ptr_to_t_string_memory_ptr_fromStack(value1,  tail)

        mstore(add(headStart, 64), sub(tail, headStart))
        tail := abi_encode_t_stringliteral_2602ee1ebf372b25bffbd066c8358edb7f611f67d29a83d531f51d21a4ab2e89_to_t_string_memory_ptr_fromStack( tail)

        abi_encode_t_bytes32_to_t_bytes32_fromStack(value2,  add(headStart, 96))

        abi_encode_t_bytes32_to_t_bytes32_fromStack(value3,  add(headStart, 128))

    }

    function abi_encode_tuple_t_bool_t_string_memory_ptr_t_stringliteral_2602ee1ebf372b25bffbd066c8358edb7f611f67d29a83d531f51d21a4ab2e89_t_int256_t_int256__to_t_bool_t_string_memory_ptr_t_string_memory_ptr_t_int256_t_int256__fromStack_reversed(headStart , value3, value2, value1, value0) -> tail {
        tail := add(headStart, 160)

        abi_encode_t_bool_to_t_bool_fromStack(value0,  add(headStart, 0))

        mstore(add(headStart, 32), sub(tail, headStart))
        tail := abi_encode_t_string_memory_ptr_to_t_string_memory_ptr_fromStack(value1,  tail)

        mstore(add(headStart, 64), sub(tail, headStart))
        tail := abi_encode_t_stringliteral_2602ee1ebf372b25bffbd066c8358edb7f611f67d29a83d531f51d21a4ab2e89_to_t_string_memory_ptr_fromStack( tail)

        abi_encode_t_int256_to_t_int256_fromStack(value2,  add(headStart, 96))

        abi_encode_t_int256_to_t_int256_fromStack(value3,  add(headStart, 128))

    }

}
