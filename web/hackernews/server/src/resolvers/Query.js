async function feed(root, args, context, info) {
    const where = args.filter ? {
        OR: [
            { description_contains: args.filter },
            { url_contains: args.filter }
        ],
    } : { }

    const links = context.prisma.links({
        where,
        skip: args.skip,
        first: args.first,
        orderBy: args.orderBy
    })
    const count = await context.prisma.linksConnection({
        where,
    }).aggregate().count()
    return {
        links,
        count
    }
}

function info(root, args, context, info) {
    return `This is the API of a Hackernews clone`
}

// link: (parent, args, context, info) => {
//     return 
// }

module.exports = { 
    feed, 
    info 
}