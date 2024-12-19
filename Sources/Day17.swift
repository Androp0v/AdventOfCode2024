import Algorithms
import Dispatch
import os

struct Day17: AdventDay {
    
    enum Instruction: UInt8 {
        case adv = 0
        case bxl = 1
        case bst = 2
        case jnz = 3
        case bxc = 4
        case out = 5
        case bdv = 6
        case cdv = 7
    }
    
    enum Operand {
        case literal(Int)
        case registerA
        case registerB
        case registerC
        case invalid
        
        init(rawValue: UInt8) {
            switch rawValue {
            case 0:
                self = .literal(0)
            case 1:
                self = .literal(1)
            case 2:
                self = .literal(2)
            case 3:
                self = .literal(3)
            case 4:
                self = .registerA
            case 5:
                self = .registerB
            case 6:
                self = .registerC
            case 7:
                self = .invalid
            default:
                fatalError()
            }
        }
        
        var asLiteral: Int {
            switch self {
            case .literal(let value):
                value
            case .registerA:
                4
            case .registerB:
                5
            case .registerC:
                6
            case .invalid:
                7
            }
        }
    }
    
    final class Machine: @unchecked Sendable {
        struct Registers {
            var instructionPointer: Int = 0
            var A: Int
            var B: Int
            var C: Int
            
            init(A: Int, B: Int, C: Int) {
                self.A = A
                self.B = B
                self.C = C
            }
        }
        var register: Registers
        var outputBuffer = [Int]()
        var debugMode: Bool = false
        
        func value(_ operand: Operand) -> Int {
            switch operand {
            case .literal(let literalValue):
                literalValue
            case .registerA:
                register.A
            case .registerB:
                register.B
            case .registerC:
                register.C
            case .invalid:
                fatalError("Invalid combo operand!")
            }
        }
        
        func debug(_ message: String, terminator: String = "\n") {
            guard debugMode else { return }
            print(message, terminator: terminator)
        }
        
        init(register: Registers) {
            self.register = register
        }
        /// Opcode 0.
        func adv(operand: Operand) {
            debug("adv \(operand)", terminator: "")
            let num = register.A
            let denom = pow2(value(operand)) // pow(2, value(operand))
            register.A = Int(Double(num) / Double(denom))
            debug(" -> Set register A to \(register.A)")
            register.instructionPointer += 2
        }
        /// Opcode 1.
        func bxl(operand: Operand) {
            debug("bxl #\(operand.asLiteral)", terminator: "")
            register.B = register.B ^ operand.asLiteral
            debug(" -> Set register B to \(register.B)")
            register.instructionPointer += 2
        }
        /// Opcode 2.
        func bst(operand: Operand) {
            debug("bst \(operand)", terminator: "")
            register.B = value(operand) % 8
            debug(" -> Set register B to \(register.B)")
            register.instructionPointer += 2
        }
        /// Opcode 3.
        func jnz(operand: Operand) {
            debug("jnz \(operand.asLiteral)", terminator: "")
            guard register.A != 0 else {
                register.instructionPointer += 2
                debug(" -> NoOp, register A == 0")
                return
            }
            register.instructionPointer = operand.asLiteral
            debug(" -> Set instruction pointer to \(register.instructionPointer)")
        }
        /// Opcode 4.
        func bxc(operand: Operand) {
            debug("bxc -", terminator: "")
            register.B = register.B ^ register.C
            debug(" -> Set register B to \(register.B)")
            register.instructionPointer += 2
        }
        /// Opcode 5.
        func out(operand: Operand) {
            debug("out \(operand)", terminator: "")
            let output = value(operand) % 8
            outputBuffer.append(output)
            debug(" -> Out: \(output)")
            register.instructionPointer += 2
        }
        /// Opcode 6.
        func bdv(operand: Operand) {
            debug("bdv \(operand)", terminator: "")
            let num = register.A
            let denom = pow2(value(operand))
            register.B = Int(Double(num) / Double(denom))
            debug(" -> Set register B to \(register.B)")
            register.instructionPointer += 2
        }
        /// Opcode 7.
        func cdv(operand: Operand) {
            debug("cdv \(operand)", terminator: "")
            let num = register.A
            let denom = pow2(value(operand))
            register.C = Int(Double(num) / Double(denom))
            debug(" -> Set register C to \(register.C)")
            register.instructionPointer += 2
        }
        
        func start(instructionStream: [InstructionCombo]) {
            while register.instructionPointer < (2 * instructionStream.count) {
                // debug("IP: \(register.instructionPointer)")
                let ip = register.instructionPointer
                guard ip % 2 == 0 else { fatalError() }
                let combo = instructionStream[ip / 2]
                let instruction = combo.instruction
                let operand = combo.operand
                switch instruction {
                case .adv:
                    adv(operand: operand)
                case .bxl:
                    bxl(operand: operand)
                case .bst:
                    bst(operand: operand)
                case .jnz:
                    jnz(operand: operand)
                case .bxc:
                    bxc(operand: operand)
                case .out:
                    out(operand: operand)
                case .bdv:
                    bdv(operand: operand)
                case .cdv:
                    cdv(operand: operand)
                }
            }
        }
    }
    
    struct InstructionCombo {
        let instruction: Instruction
        let operand: Operand
    }
    
    let initialState: Machine.Registers
    let instructionStream: [InstructionCombo]
    let rawInstructionStream: [Int]
    
    // MARK: - Init
    
    init(data: String) {
        var stream = [InstructionCombo]()
        var rawStream = [Int]()
        var registerA: Int?
        var registerB: Int?
        var registerC: Int?
        for line in data.split(separator: "\n") {
            if line.starts(with: "Register A") {
                registerA = Int(line.replacingOccurrences(of: "Register A: ", with: ""))
            } else if line.starts(with: "Register B") {
                registerB = Int(line.replacingOccurrences(of: "Register B: ", with: ""))
            }  else if line.starts(with: "Register C") {
                registerC = Int(line.replacingOccurrences(of: "Register C: ", with: ""))
            } else if line.starts(with: "Program") {
                let rawInstructions = line
                    .replacingOccurrences(of: "Program: ", with: "")
                    .split(separator: ",")
                for index in 0..<(rawInstructions.count / 2) {
                    stream.append(InstructionCombo(
                        instruction: Instruction(rawValue: UInt8(rawInstructions[2 * index])!)!,
                        operand: Operand(rawValue: UInt8(rawInstructions[2 * index + 1])!)
                    ))
                    rawStream.append(Int(rawInstructions[2 * index])!)
                    rawStream.append(Int(rawInstructions[2 * index + 1])!)
                }
            }
        }
        self.initialState = Machine.Registers(A: registerA!, B: registerB!, C: registerC!)
        self.instructionStream = stream
        self.rawInstructionStream = rawStream
    }

    // MARK: - Part 1
    
    // Replace this with your solution for the first part of the day's challenge.
    func part1() -> Any {
        let machine = Machine(register: initialState)
        machine.start(instructionStream: instructionStream)
        return String(machine.outputBuffer.map( { String($0) } ).joined(by: ","))
    }
        
    func findRegisterA() -> Int? {
        var result: Int?
        func innerFind(registerA: Int, depth: Int, result: inout Int?) {
            let machine = Machine(register: initialState)
            machine.register.A = registerA
            machine.start(instructionStream: instructionStream)
            if machine.outputBuffer == rawInstructionStream {
                guard result == nil else { return }
                result = registerA
            } else if machine.outputBuffer == rawInstructionStream.suffix(depth) || depth == 0 {
                for offset in 0..<8 {
                    innerFind(
                        registerA: 8 * registerA + offset,
                        depth: depth + 1,
                        result: &result
                    )
                }
            }
        }
        innerFind(registerA: 0, depth: 0, result: &result)
        return result
    }

    // MARK: - Part 2
    // Replace this with your solution for the second part of the day's challenge.
    func part2() async -> Any {
        return findRegisterA()!
    }
}

// MARK: - Utils

extension Day17 {
    final class FastComparator {
        var rawInstructionStream: [Int]
        
        var next: Int? {
            guard !rawInstructionStream.isEmpty else { return nil }
            return rawInstructionStream.remove(at: 0)
        }
        
        init(rawInstructionStream: [Int]) {
            self.rawInstructionStream = rawInstructionStream
        }
    }
}

extension Day17.Instruction: CustomStringConvertible {
    var description: String {
        switch self {
        case .adv:
            return "adv"
        case .bxl:
            return "bxl"
        case .bst:
            return "bst"
        case .jnz:
            return "jnz"
        case .bxc:
            return "bxc"
        case .out:
            return "out"
        case .bdv:
            return "bdv"
        case .cdv:
            return "cdv"
        }
    }
}

extension Day17.Operand: CustomStringConvertible {
    var description: String {
        switch self {
        case .literal(let value):
            "#\(value)"
        case .registerA:
            "rA"
        case .registerB:
            "rB"
        case .registerC:
            "rC"
        case .invalid:
            "!!!"
        }
    }
}

extension Day17.InstructionCombo: CustomStringConvertible {
    var description: String {
        "\(instruction) \(operand)"
    }
}

fileprivate func pow2(_ power: Int) -> Int {
    return 1<<power
}


