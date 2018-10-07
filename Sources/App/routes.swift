import Routing
import Vapor

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {
    router.post(Poll.self, at: "polls","create") { req, poll -> Future<Poll> in
        var finalPoll = poll
        finalPoll.password = random(4)
        return finalPoll.save(on: req)
    }
    
    router.get("polls","list") { req -> Future<[Poll]> in
        return Poll.query(on: req).all().map(to: [Poll].self) { polls in
            var newPolls = [Poll]()
            for poll in polls {
                var p = poll
                p.password = nil
                newPolls.append(p)
            }
            
            return newPolls
        }
    }
    
    router.get("polls", UUID.parameter) { req -> Future<Poll> in
        let id = try req.parameters.next(UUID.self)
        
        return Poll.find(id, on: req).unwrap(or: Abort(.notFound)).map(to: Poll.self) {poll in
            var newPoll = poll
            newPoll.password = nil
            return newPoll
        }
    }
    
    router.delete("polls", UUID.parameter, String.parameter) { req -> Future<Poll> in
        let id = try req.parameters.next(UUID.self)
        let password = try req.parameters.next(String.self)
        
        let poll = Poll.find(id, on: req).unwrap(or: Abort(.notFound)).map(to: Poll.self) { poll in
            if (poll.password == password) {
                poll.delete(on: req)
            } else {
                throw Abort(HTTPResponseStatus.unauthorized)
            }
            
            return poll
        }
        
        
        return poll
    }
    
    router.post("polls","vote", UUID.parameter, Int.parameter) { req -> Future<Poll> in
        let id = try req.parameters.next(UUID.self)
        let vote = try req.parameters.next(Int.self)
        
        return Poll.find(id, on: req).flatMap(to: Poll.self) {
            poll in
            guard var poll = poll else {
                throw Abort(.notFound)
            }
            if(vote == 1) {
                poll.votes1 += 1
            } else {
                poll.votes2 += 1
            }
            
            return poll.save(on: req)
        }
    }
}

func random(_ n: Int) -> String
{
    let a = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
    
    var s = ""
    
    for _ in 0..<n
    {
        let r = Int(arc4random_uniform(UInt32(a.characters.count)))
        
        s += String(a[a.index(a.startIndex, offsetBy: r)])
    }
    
    return s
}
