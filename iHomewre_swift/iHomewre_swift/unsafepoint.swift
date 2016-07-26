//
//  unsafepoint.swift
//  iHomewre_swift
//
//  Created by mac on 16/7/14.
//  Copyright © 2016年 mac. All rights reserved.
//

import Foundation
import SystemConfiguration.CaptiveNetwork

// 指针操作
class unsafeclass {
    

    
    enum NetCID: UInt8 {
        case GatewayCID = 0x000E
        case CredentialAskCID = 0x0010
    }
    private (set) var allSearchGatwayArr: [String] = Array()
    let MaxBufferSize = 2048
    let UDPDiscoveryGetwayPort: UInt16 = 4156
    let GateWayPort : UInt16 = 1234
    let PackageStart:UInt8 = 0xfe
    let RequestStart:UInt8 = 0x00
    let ResponseStart:UInt8 = 0x01
    let PackageEnd:UInt8 = 0xff
    
    //只需要申请一块内存  http://swifter.tips/pointer-memory/
    var pWrite: UnsafeMutablePointer<UInt8> = UnsafeMutablePointer<UInt8>.alloc(1)
    func sendCommandToGatewayOld(cID: Int,len: Int, listLen: Int8, pData: [UInt8]? )  {
        var nWriteBytes = 0
        
        print(pWrite.memory)
        print(pWrite)
        var bytes = [UInt8]()
        
        //PackageStart 0xFE 1Byte
        var packageStart:UInt8 = PackageStart
        memcpy(pWrite, &packageStart, 1)
        nWriteBytes = nWriteBytes + 1
        bytes.append(pWrite.memory)
        
        //RequestStart 0x00 1Byte
        var requestStart = RequestStart
        memcpy(pWrite, &requestStart, 1)
        nWriteBytes = nWriteBytes + 1
        bytes.append(pWrite.memory)
        
        //CommondID 2Byte
        var firstCommondID: Int8 = Int8(cID / 256)
        memcpy(pWrite, &firstCommondID, 1)
        nWriteBytes = nWriteBytes + 1
        bytes.append(pWrite.memory)
        
        var secondCommondID: Int8 = Int8(cID % 256)
        memcpy(pWrite, &secondCommondID, 1)
        nWriteBytes = nWriteBytes + 1
        bytes.append(pWrite.memory)
        
        //Length 2Byte
        memset(pWrite, Int32(len / 256), 1)
        nWriteBytes = nWriteBytes + 1
        bytes.append(pWrite.memory)
        
        memset(pWrite, Int32(len % 256), 1)
        nWriteBytes = nWriteBytes + 1
        bytes.append(pWrite.memory)
        
        //ListLength 2Byte
        memset(pWrite, 0, 1)
        nWriteBytes = nWriteBytes + 1
        bytes.append(pWrite.memory)
        
        var nlistLen = listLen
        memcpy(pWrite, &nlistLen, 1);
        nWriteBytes = nWriteBytes + 1
        
        bytes.append(pWrite.memory)
        var FCS = bytes[2] ^ bytes[3]
        for var i in 4..<nWriteBytes {
            FCS = FCS ^ bytes[i]
        }
        
        if !(pData == nil) {
            bytes = bytes + pData!
            nWriteBytes = nWriteBytes + pData!.count
            for var i in 0..<pData!.count {
                FCS = FCS ^ pData![i]
            }
        }
        
        memcpy(pWrite, &FCS, 1);
        nWriteBytes = nWriteBytes + 1
        bytes.append(pWrite.memory)
        
        //END 2Byte
        var packageEnd = PackageEnd;
        memset(pWrite, 0, 1);
        nWriteBytes = nWriteBytes + 1
        bytes.append(pWrite.memory)
        
        memcpy(pWrite, &packageEnd, 1);
        nWriteBytes = nWriteBytes + 1
        bytes.append(pWrite.memory)
        
        
        let data2 = NSData(bytes: &bytes,length: nWriteBytes * sizeof(UInt8))
        print(data2)
        
        //        pWrite = nil
    }
    // MARK: - 解析ip(老方法)
    func parserGetwayIPAddress(data: NSData) -> [String]? {
  
        //typedef unsigned char                   UInt8;
        let len = data.length
        let pData:UnsafePointer<UInt8> = UnsafePointer<UInt8>(data.bytes)
        
        guard len > 0 && pData.memory != 0 else { return nil}
        
        let packageStart = pData.memory
        let responseStart = (pData+1).memory
        guard packageStart == PackageStart && responseStart == ResponseStart else { return nil}
        
        //CommandID
        let subCommandID1 = (pData+2).memory
        let subCommandID2 = (pData+3).memory
        let commandID = subCommandID1 * 16 + subCommandID2;
        guard commandID == UInt8( NetCID.GatewayCID.rawValue ) else{ return nil}
        
        //Length
        let subLength1 = (pData+4).memory
        let subLength2 = (pData+5).memory
        _ = subLength1 * 16 + subLength2;
        //ListLength
        let subListLength1 = (pData+6).memory
        let subListLength2 = (pData+7).memory
        let listLength = subListLength1 * 16 + subListLength2;
        
        guard listLength == 0x00 else{
            if allSearchGatwayArr.count != 0 {
                return allSearchGatwayArr
            }
            return nil
        }
        let firstIP = (pData+8).memory
        let secondIP = (pData+9).memory
        let thirdIP = (pData+10).memory
        let forthIP = (pData+11).memory
        let gatwayIP = "\(firstIP).\(secondIP).\(thirdIP).\(forthIP)"
        guard !allSearchGatwayArr.contains(gatwayIP) else{ return allSearchGatwayArr}
        
        allSearchGatwayArr.append(gatwayIP)
        return allSearchGatwayArr
    }

}
