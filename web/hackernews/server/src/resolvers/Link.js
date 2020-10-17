function postedBy(parent, args, context, info) {
    return context.prisma.link({ id: parent.id }).postedBy()
}

function votes(parent, args, context) {
    return context.prisma.link({ id: parent.id }).votes()
}

// Link: {
//     id: (parent) => parent.id,
//     description: (parent) => parent.description,
//     url: (parent) => parent.url
// }

module.exports = {
    postedBy,
    votes
}