// Copyright (c) 2017, Anatoly Pulyaevskiy. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.
import 'dart:async';
import 'dart:js';
import 'dart:typed_data';

import 'package:node_interop/dns.dart';
import 'package:node_interop/net.dart';

import 'http_common.dart' as common;

/// An internet address.
///
/// This object holds an internet address. If this internet address
/// is the result of a DNS lookup, the address also holds the hostname
/// used to make the lookup.
/// An Internet address combined with a port number represents an
/// endpoint to which a socket can connect or a listening socket can
/// bind.
class InternetAddress implements common.InternetAddress {
  // static const int _ipv6AddrLength = 16;

  final String? _host;

  // final Uint8List _inAddr;

  @override
  final String address;

  //@override
  String get host => _host ?? address;

  @override
  common.InternetAddressType get type => net.isIPv4(address)
      ? common.InternetAddressType.IPv4
      : common.InternetAddressType.IPv6;

  InternetAddress._(this.address, [this._host])
  //: _inAddr = _inet_pton(address)
  {
    if (net.isIP(address) == 0) {
      throw ArgumentError('$address is not valid.');
    }
  }

  /// Creates a new [InternetAddress] from a numeric address.
  ///
  /// If the address in [address] is not a numeric IPv4
  /// (dotted-decimal notation) or IPv6 (hexadecimal representation).
  /// address [ArgumentError] is thrown.
  factory InternetAddress(String address) => InternetAddress._(address);

  /// Lookup a host, returning a Future of a list of
  /// [InternetAddress]s. If [type] is [InternetAddressType.ANY], it
  /// will lookup both IP version 4 (IPv4) and IP version 6 (IPv6)
  /// addresses. If [type] is either [InternetAddressType.IPv4] or
  /// [InternetAddressType.IPv6] it will only lookup addresses of the
  /// specified type. The order of the list can, and most likely will,
  /// change over time.
  static Future<List<InternetAddress>> lookup(String host) {
    final completer = Completer<List<InternetAddress>>();
    final options = DNSLookupOptions(all: true, verbatim: true);

    void handleLookup(error, result) {
      if (error != null) {
        completer.completeError(error as Object);
      } else {
        final addresses = List<DNSAddress>.from(result as List);
        var list = addresses
            .map((item) => InternetAddress._(item.address, host))
            .toList(growable: false);
        completer.complete(list);
      }
    }

    dns.lookup(host, options, allowInterop(handleLookup));
    return completer.future;
  }

  /*
  @override
  bool get isLinkLocal {
    // Copied from dart:io
    if (type == common.InternetAddressType.IPv4) {
      // Checking for 169.254.0.0/16.
      return _inAddr[0] == 169 && _inAddr[1] == 254;
    } else if (type == common.InternetAddressType.IPv6) {
      // Checking for fe80::/10.
      return _inAddr[0] == 0xFE && (_inAddr[1] & 0xB0) == 0x80;
    }
    throw StateError('Unreachable');
  }

  @override
  bool get isLoopback {
    // Copied from dart:io
    if (type == common.InternetAddressType.IPv4) {
      return _inAddr[0] == 127;
    } else if (type == common.InternetAddressType.IPv6) {
      for (var i = 0; i < _ipv6AddrLength - 1; i++) {
        if (_inAddr[i] != 0) return false;
      }
      return _inAddr[_ipv6AddrLength - 1] == 1;
    }
    throw StateError('Unreachable');
  }

  @override
  bool get isMulticast {
    // Copied from dart:io
    if (type == common.InternetAddressType.IPv4) {
      // Checking for 224.0.0.0 through 239.255.255.255.
      return _inAddr[0] >= 224 && _inAddr[0] < 240;
    } else if (type == common.InternetAddressType.IPv6) {
      // Checking for ff00::/8.
      return _inAddr[0] == 0xFF;
    }
    throw StateError('Unreachable');
  }

  @override
  Uint8List get rawAddress => Uint8List.fromList(_inAddr);

  @override
  Future<InternetAddress> reverse() {
    final completer = Completer<InternetAddress>();
    void reverseResult(error, result) {
      if (error != null) {
        completer.completeError(error as Object);
      } else {
        final hostnames = List<String>.from(result as List);
        completer.complete(InternetAddress._(address, hostnames.first));
      }
    }

    dns.reverse(address, allowInterop(reverseResult));
    return completer.future;
  }
  */
  @override
  String toString() => address;
}

const int _kColon = 58;

/// Best-effort implementation of native inet_pton.
///
/// This implementation assumes that [ip] address has been validated for
/// correctness.
// ignore: non_constant_identifier_names, unused_element
Uint8List _inet_pton(String ip) {
  if (ip.contains(':')) {
    // ipv6
    final result = Uint8List(16);

    // Special cases:
    if (ip == '::') return result;
    if (ip == '::1') return result..[15] = 1;

    const maxSingleColons = 7;

    final totalColons = ip.codeUnits.where((code) => code == _kColon).length;
    final hasDoubleColon = ip.contains('::');
    final singleColons = hasDoubleColon ? (totalColons - 1) : totalColons;
    final skippedSegments = maxSingleColons - singleColons;

    final segment = StringBuffer();
    var pos = 0;
    for (var i = 0; i < ip.length; i++) {
      if (i > 0 && ip[i] == ':' && ip[i - 1] == ':') {
        /// We don't need to set bytes to zeros as our [result] array is
        /// prefilled with zeros already, so we just need to shift our position
        /// forward.
        pos += 2 * skippedSegments;
      } else if (ip[i] == ':') {
        if (segment.isEmpty) segment.write('0');
        final value = int.parse(segment.toString(), radix: 16);
        result[pos] = value ~/ 256;
        result[pos + 1] = value % 256;
        pos += 2;
        segment.clear();
      } else {
        segment.write(ip[i]);
      }
    }
    // Don't forget about the last segment:
    if (segment.isEmpty) segment.write('0');
    final value = int.parse(segment.toString(), radix: 16);
    result[pos] = value ~/ 256;
    result[pos + 1] = value % 256;
    return result;
  } else {
    // ipv4
    return Uint8List.fromList(ip.split('.').map(int.parse).toList());
  }
}
