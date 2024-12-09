import Algorithms

struct Day09: AdventDay {
    
    struct FileBlock: DiskBlock {
        let type = DiskBlockType.file
        let id: Int
        let length: Int
    }
    
    struct FreeSpace: DiskBlock {
        let type = DiskBlockType.freeSpace
        let length: Int
    }
    
    protocol DiskBlock: Sendable {
        var type: DiskBlockType { get }
        var length: Int { get }
    }
    
    enum DiskBlockType {
        case file
        case freeSpace
    }
    
    let diskBlocks: [DiskBlock]
    
    init(data: String) {
        var isFile: Bool = true
        var currentFileIndex: Int = 0
        var blocks = [DiskBlock]()
        for character in data {
            guard character != "\n" else { break }
            if isFile {
                blocks.append(
                    FileBlock(
                        id: currentFileIndex,
                        length: Int(String(character))!
                    )
                )
                currentFileIndex += 1
            } else {
                blocks.append(
                    FreeSpace(length: Int(String(character))!)
                )
            }
            isFile.toggle()
        }
        self.diskBlocks = blocks
    }
    
    func nextSpaceIndex(in blocks: [DiskBlock]) -> Int {
        return blocks.firstIndex(where: { $0.type == .freeSpace })!
    }
    
    func nextSpaceIndexIfPossible(in blocks: [DiskBlock], size: Int, fileIndex: Int) -> Int? {
        guard let spaceIndex = blocks.firstIndex(where: {
            $0.type == .freeSpace && $0.length >= size
        }) else {
            return nil
        }
        guard spaceIndex < fileIndex else {
            return nil
        }
        return spaceIndex
    }
    
    func isCompacted(_ blocks: [DiskBlock]) -> Bool {
        blocks.lastIndex(where: { $0.type == .file })! < blocks.firstIndex(where: { $0.type == .freeSpace })!
    }

    // Replace this with your solution for the first part of the day's challenge.
    func part1() -> Any {
        var rearrangedBlocks: [DiskBlock] = diskBlocks
        var leftmostSpaceIndex: Int = nextSpaceIndex(in: rearrangedBlocks)
        while !isCompacted(rearrangedBlocks) {
            let pendingFileIndex = rearrangedBlocks.lastIndex(where: { $0.type == .file })!
            var pendingFile = rearrangedBlocks.remove(at: pendingFileIndex) as! FileBlock
            while true {
                let availableSpace = rearrangedBlocks[leftmostSpaceIndex] as! FreeSpace
                if availableSpace.length == pendingFile.length {
                    rearrangedBlocks[leftmostSpaceIndex] = pendingFile
                    leftmostSpaceIndex = nextSpaceIndex(in: rearrangedBlocks)
                    rearrangedBlocks.append(FreeSpace(length: availableSpace.length))
                    break
                } else if availableSpace.length > pendingFile.length {
                    rearrangedBlocks.insert(pendingFile, at: leftmostSpaceIndex)
                    leftmostSpaceIndex += 1
                    rearrangedBlocks[leftmostSpaceIndex] = FreeSpace(
                        length: availableSpace.length - pendingFile.length
                    )
                    rearrangedBlocks.append(FreeSpace(length: pendingFile.length))
                    break
                } else if availableSpace.length < pendingFile.length {
                    rearrangedBlocks[leftmostSpaceIndex] = FileBlock(
                        id: pendingFile.id,
                        length: availableSpace.length
                    )
                    rearrangedBlocks.append(FreeSpace(length: availableSpace.length))
                    leftmostSpaceIndex = nextSpaceIndex(in: rearrangedBlocks)
                    pendingFile = FileBlock(
                        id: pendingFile.id,
                        length: pendingFile.length - availableSpace.length
                    )
                } else {
                    fatalError()
                }
            }
        }
        
        var checksum = 0
        var index = 0
        for file in rearrangedBlocks.filter({ $0.type == .file }).map({ $0 as! FileBlock }) {
            for _ in 0..<file.length {
                checksum += index * file.id
                index += 1
            }
        }
        return checksum
    }

    // Replace this with your solution for the second part of the day's challenge.
    func part2() -> Any {
        var rearrangedBlocks: [DiskBlock] = diskBlocks
        
        for (index, block) in diskBlocks.enumerated().reversed() {
            guard block.type == .file else { continue }
            let currentFile = diskBlocks[index] as! FileBlock
            
            let fileIndex = rearrangedBlocks
                .firstIndex(where: {
                    guard $0.type == .file else { return false }
                    let file = $0 as! FileBlock
                    return file.id == currentFile.id
                })!
            
            guard let availableSpaceIndex = nextSpaceIndexIfPossible(
                in: rearrangedBlocks,
                size: currentFile.length,
                fileIndex: fileIndex
            ) else {
                continue
            }
            let availableSpace = rearrangedBlocks[availableSpaceIndex] as! FreeSpace
            
            if availableSpace.length == currentFile.length {
                rearrangedBlocks[availableSpaceIndex] = currentFile
                rearrangedBlocks[fileIndex] = FreeSpace(length: currentFile.length)
            } else if availableSpace.length > currentFile.length {
                rearrangedBlocks.insert(currentFile, at: availableSpaceIndex)
                rearrangedBlocks[availableSpaceIndex + 1] = FreeSpace(
                    length: availableSpace.length - currentFile.length
                )
                rearrangedBlocks[fileIndex + 1] = FreeSpace(length: currentFile.length)
            } else {
                fatalError()
            }
        }
        
        var checksum = 0
        var index = 0
        for block in rearrangedBlocks {
            switch block.type {
            case .file:
                let file = block as! FileBlock
                for _ in 0..<file.length {
                    checksum += index * file.id
                    index += 1
                }
            case .freeSpace:
                let freeSpace = block as! FreeSpace
                for _ in 0..<freeSpace.length {
                    index += 1
                }
            }
        }
        return checksum
    }
}
